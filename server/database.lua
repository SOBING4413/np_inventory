Database = {
  backend = 'memory',
  memory = {},
}

local function isStarted(resource)
  return GetResourceState(resource) == 'started'
end

local function safeJsonDecode(value, fallback)
  if type(value) ~= 'string' then return fallback end
  local ok, decoded = pcall(json.decode, value)
  if not ok or type(decoded) ~= 'table' then return fallback end
  return decoded
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
      CREATE TABLE IF NOT EXISTS np_inventory_players (
        identifier VARCHAR(80) NOT NULL,
        inventory LONGTEXT NOT NULL,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (identifier)
      )
    ]], {}, function() end)
  elseif self.backend == 'mysql-async' then
    MySQL.Async.execute([[
      CREATE TABLE IF NOT EXISTS np_inventory_players (
        identifier VARCHAR(80) NOT NULL,
        inventory LONGTEXT NOT NULL,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (identifier)
      )
    ]], {})
  end
end

function Database:getInventory(identifier, cb)
  if self.backend == 'memory' then
    cb(self.memory[identifier] or {})
    return
  end

  local sql = 'SELECT inventory FROM np_inventory_players WHERE identifier = ? LIMIT 1'

  if self.backend == 'oxmysql' then
    exports.oxmysql:query(sql, { identifier }, function(result)
      local row = result and result[1]
      if not row then
        cb({})
        return
      end

      cb(safeJsonDecode(row.inventory, {}))
    end)
    return
  end

  MySQL.Async.fetchAll(sql, { identifier }, function(result)
    local row = result and result[1]
    if not row then
      cb({})
      return
    end

    cb(safeJsonDecode(row.inventory, {}))
  end)
end

function Database:saveInventory(identifier, inventory, cb)
  local encoded = json.encode(inventory or {})

  if self.backend == 'memory' then
    self.memory[identifier] = inventory or {}
    if cb then cb(true) end
    return
  end

  local sql = [[
    INSERT INTO np_inventory_players (identifier, inventory)
    VALUES (?, ?)
    ON DUPLICATE KEY UPDATE inventory = VALUES(inventory)
  ]]

  if self.backend == 'oxmysql' then
    exports.oxmysql:query(sql, { identifier, encoded }, function()
      if cb then cb(true) end
    end)
    return
  end

  MySQL.Async.execute(sql, { identifier, encoded }, function()
    if cb then cb(true) end
  end)
end
