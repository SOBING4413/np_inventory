local function getProfile(invType)
  local profile = Config.InventoryProfiles[invType] or Config.InventoryProfiles.player
  return {
    slots = tonumber(profile.slots) or Config.DefaultSlots,
    maxWeight = tonumber(profile.maxWeight) or Config.DefaultMaxWeight,
  }
end

local function makeEmptyInventory(invType)
  local profile = getProfile(invType)
  local slots = {}
  for i = 1, profile.slots do
    slots[i] = false
  end

  return {
    slots = slots,
    maxWeight = profile.maxWeight,
    slotCount = profile.slots,
  }
end

local function normalizeInventory(inv, invType)
  if type(inv) ~= 'table' then
    return makeEmptyInventory(invType)
  end

  local profile = getProfile(invType)
  inv.slotCount = tonumber(inv.slotCount) or profile.slots
  inv.maxWeight = tonumber(inv.maxWeight) or profile.maxWeight
  inv.slots = type(inv.slots) == 'table' and inv.slots or {}

  for i = 1, inv.slotCount do
    if inv.slots[i] == nil then
      inv.slots[i] = false
    end
  end

  return inv
end

local function sanitizeName(value, fallback)
  value = tostring(value or fallback or 'default')
  value = value:gsub('[^%w_%-:]', '_')
  if value == '' then
    return fallback or 'default'
  end
  return value
end

local function resolveInventoryIdentity(source, invType, invName)
  invType = sanitizeName(invType, 'player')
  invName = sanitizeName(invName, 'player')

  local owner = Framework:getIdentifier(source)
  if invType == 'player' then
    return owner, invType, 'player'
  end

  if invType == 'stash' then
    return 'shared', invType, invName
  end

  if invType == 'trunk' or invType == 'glovebox' or invType == 'drop' then
    return 'shared', invType, invName
  end

  return owner, invType, invName
end

local function fetchInventory(source, invType, invName, cb)
  local owner, resolvedType, resolvedName = resolveInventoryIdentity(source, invType, invName)
  Database:getNamedInventory(owner, resolvedType, resolvedName, function(inventory)
    cb(normalizeInventory(inventory, resolvedType), owner, resolvedType, resolvedName)
  end)
end

local function syncInventoryToClient(source, invType, invName, inventory)
  TriggerClientEvent('np_inventory:client:syncInventory', source, {
    inventory = inventory,
    context = {
      type = invType,
      name = invName,
    },
  })
end

RegisterNetEvent('np_inventory:server:requestInventory', function(invType, invName)
  local src = source
  fetchInventory(src, invType, invName, function(inventory, _, resolvedType, resolvedName)
    syncInventoryToClient(src, resolvedType, resolvedName, inventory)
  end)
end)

RegisterNetEvent('np_inventory:server:saveNamedInventory', function(invType, invName, inventory)
  local src = source
  if type(inventory) ~= 'table' then return end

  local owner, resolvedType, resolvedName = resolveInventoryIdentity(src, invType, invName)
  Database:saveNamedInventory(owner, resolvedType, resolvedName, normalizeInventory(inventory, resolvedType))
end)

RegisterNetEvent('np_inventory:server:saveInventory', function(inventory)
  local src = source
  if type(inventory) ~= 'table' then return end

  local owner, resolvedType, resolvedName = resolveInventoryIdentity(src, 'player', 'player')
  Database:saveNamedInventory(owner, resolvedType, resolvedName, normalizeInventory(inventory, resolvedType))
end)

RegisterNetEvent('np_inventory:server:moveSlot', function(invType, invName, fromSlot, toSlot)
  local src = source
  fromSlot = tonumber(fromSlot)
  toSlot = tonumber(toSlot)

  if not fromSlot or not toSlot then return end
  if fromSlot < 1 or toSlot < 1 then return end

  fetchInventory(src, invType, invName, function(inventory, owner, resolvedType, resolvedName)
    if fromSlot > inventory.slotCount or toSlot > inventory.slotCount then return end

    local temp = inventory.slots[fromSlot]
    inventory.slots[fromSlot] = inventory.slots[toSlot]
    inventory.slots[toSlot] = temp

    Database:saveNamedInventory(owner, resolvedType, resolvedName, inventory)
    syncInventoryToClient(src, resolvedType, resolvedName, inventory)
  end)
end)

exports('OpenInventory', function(source, invType, data)
  local name = data
  if type(data) == 'table' then
    name = data.id or data.name or data.plate or data.stash
  end

  fetchInventory(source, invType or 'player', name or 'player', function(inventory, _, resolvedType, resolvedName)
    syncInventoryToClient(source, resolvedType, resolvedName, inventory)
  end)

  return true
end)

exports('GetInventory', function(source, cbOrType, maybeName)
  if type(cbOrType) == 'function' or cbOrType == nil then
    local cb = cbOrType
    if cb then
      fetchInventory(source, 'player', 'player', function(inventory)
        cb(inventory)
      end)
      return
    end

    local p = promise.new()
    fetchInventory(source, 'player', 'player', function(inventory)
      p:resolve(inventory)
    end)

    return Citizen.Await(p)
  end

  local invType = tostring(cbOrType)
  local invName = maybeName or invType
  local p = promise.new()

  fetchInventory(source, invType, invName, function(inventory)
    p:resolve(inventory)
  end)

  return Citizen.Await(p)
end)

exports('SetInventory', function(source, inventoryOrType, maybeName, maybeInventory)
  if type(inventoryOrType) == 'table' then
    local owner, resolvedType, resolvedName = resolveInventoryIdentity(source, 'player', 'player')
    local normalized = normalizeInventory(inventoryOrType, resolvedType)
    Database:saveNamedInventory(owner, resolvedType, resolvedName, normalized)
    syncInventoryToClient(source, resolvedType, resolvedName, normalized)
    return true
  end

  local invType = tostring(inventoryOrType or 'player')
  local invName = maybeName or invType
  local inventory = maybeInventory
  if type(inventory) ~= 'table' then
    return false
  end

  local owner, resolvedType, resolvedName = resolveInventoryIdentity(source, invType, invName)
  local normalized = normalizeInventory(inventory, resolvedType)

  Database:saveNamedInventory(owner, resolvedType, resolvedName, normalized)
  syncInventoryToClient(source, resolvedType, resolvedName, normalized)

  return true
end)

AddEventHandler('onResourceStart', function(resource)
  if resource ~= GetCurrentResourceName() then return end

  Framework:init()
  Database:init()
end)
