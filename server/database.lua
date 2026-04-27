Database = {
  backend = 'memory',
  memory = {},
}

local function deepCopy(value)
  if type(value) ~= 'table' then
    return value
  end

  local copy = {}
  for k, v in pairs(value) do
    copy[k] = deepCopy(v)
  end

  return copy
end

local function isStarted(resource)
  return GetResourceState(resource) == 'started'
end

local function safeJsonDecode(value, fallback)
  if type(value) ~= 'string' then return fallback end
  local ok, decoded = pcall(json.decode, value)
  if not ok or type(decoded) ~= 'table' then return fallback end
  return decoded
end

local function makeMemoryKey(owner, invType, invName)
  return ('%s:%s:%s'):format(owner, invType, invName)
end

function Database:detectBackend()
  if Config.Database ~= 'auto' then
    return Config.Database
  end

  if isStarted('oxmysql') then
    return 'oxmysql'
  end

  if isStarted('mysql-async') then
    return 'mysql-async'
  end

  return 'memory'
end

function Database:init()
  self.backend = self:detectBackend()
  print(('[%s] Database backend: %s'):format(GetCurrentResourceName(), self.backend))

  if self.backend == 'oxmysql' then
    exports.oxmysql:query([[
      CREATE TABLE IF NOT EXISTS np_inventory_data (
        inventory_key VARCHAR(160) NOT NULL,
        owner VARCHAR(80) NOT NULL,
        inv_type VARCHAR(20) NOT NULL,
        inv_name VARCHAR(80) NOT NULL,
        inventory LONGTEXT NOT NULL,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (inventory_key),
        KEY idx_owner_type (owner, inv_type)
      )
    ]], {}, function() end)
    return
  end

  if self.backend == 'mysql-async' then
    MySQL.Async.execute([[
      CREATE TABLE IF NOT EXISTS np_inventory_data (
        inventory_key VARCHAR(160) NOT NULL,
        owner VARCHAR(80) NOT NULL,
        inv_type VARCHAR(20) NOT NULL,
        inv_name VARCHAR(80) NOT NULL,
        inventory LONGTEXT NOT NULL,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (inventory_key),
        KEY idx_owner_type (owner, inv_type)
      )
    ]], {})
  end
end

function Database:getNamedInventory(owner, invType, invName, cb)
  if self.backend == 'memory' then
    cb(deepCopy(self.memory[makeMemoryKey(owner, invType, invName)] or {}))
    return
  end

  local sql = 'SELECT inventory FROM np_inventory_data WHERE inventory_key = ? LIMIT 1'
  local key = makeMemoryKey(owner, invType, invName)

  if self.backend == 'oxmysql' then
    exports.oxmysql:query(sql, { key }, function(result)
      local row = result and result[1]
      if not row then
        cb({})
        return
      end

      cb(safeJsonDecode(row.inventory, {}))
    end)
    return
  end

  MySQL.Async.fetchAll(sql, { key }, function(result)
    local row = result and result[1]
    if not row then
      cb({})
      return
    end

    cb(safeJsonDecode(row.inventory, {}))
  end)
end

function Database:saveNamedInventory(owner, invType, invName, inventory, cb)
  local encoded = json.encode(inventory or {})
  local key = makeMemoryKey(owner, invType, invName)

  if self.backend == 'memory' then
    self.memory[key] = deepCopy(inventory or {})
    if cb then cb(true) end
    return
  end

  local sql = [[
    INSERT INTO np_inventory_data (inventory_key, owner, inv_type, inv_name, inventory)
    VALUES (?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE inventory = VALUES(inventory)
  ]]

  local params = { key, owner, invType, invName, encoded }

  if self.backend == 'oxmysql' then
    exports.oxmysql:query(sql, params, function()
      if cb then cb(true) end
    end)
    return
  end

  MySQL.Async.execute(sql, params, function()
    if cb then cb(true) end
  end)
end

-- Backward compatible wrappers (player inventory)
function Database:getInventory(identifier, cb)
  self:getNamedInventory(identifier, 'player', 'player', cb)
end

function Database:saveInventory(identifier, inventory, cb)
  self:saveNamedInventory(identifier, 'player', 'player', inventory, cb)
end
