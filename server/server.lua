local function makeEmptyInventory()
  local slots = {}
  for i = 1, Config.DefaultSlots do
    slots[i] = false
  end

  return {
    slots = slots,
    maxWeight = Config.DefaultMaxWeight,
    slotCount = Config.DefaultSlots,
  }
end

local function normalizeInventory(inv)
  if type(inv) ~= 'table' then
    return makeEmptyInventory()
  end

  inv.slotCount = tonumber(inv.slotCount) or Config.DefaultSlots
  inv.maxWeight = tonumber(inv.maxWeight) or Config.DefaultMaxWeight
  inv.slots = type(inv.slots) == 'table' and inv.slots or {}

  for i = 1, inv.slotCount do
    if inv.slots[i] == nil then
      inv.slots[i] = false
    end
  end

  return inv
end

local function getPlayerInventory(source, cb)
  local identifier = Framework:getIdentifier(source)
  Database:getInventory(identifier, function(inventory)
    cb(normalizeInventory(inventory), identifier)
  end)
end

RegisterNetEvent('np_inventory:server:saveInventory', function(inventory)
  local src = source
  if type(inventory) ~= 'table' then return end

  local identifier = Framework:getIdentifier(src)
  Database:saveInventory(identifier, normalizeInventory(inventory))
end)

RegisterNetEvent('np_inventory:server:moveSlot', function(fromSlot, toSlot)
  local src = source
  fromSlot = tonumber(fromSlot)
  toSlot = tonumber(toSlot)

  if not fromSlot or not toSlot then return end
  if fromSlot < 1 or toSlot < 1 then return end

  getPlayerInventory(src, function(inventory, identifier)
    if fromSlot > inventory.slotCount or toSlot > inventory.slotCount then return end

    local temp = inventory.slots[fromSlot]
    inventory.slots[fromSlot] = inventory.slots[toSlot]
    inventory.slots[toSlot] = temp

    Database:saveInventory(identifier, inventory)
    TriggerClientEvent('np_inventory:client:syncInventory', src, inventory)
  end)
end)

exports('GetInventory', function(source, cb)
  if cb then
    getPlayerInventory(source, function(inventory)
      cb(inventory)
    end)
    return
  end

  local p = promise.new()
  getPlayerInventory(source, function(inventory)
    p:resolve(inventory)
  end)

  return Citizen.Await(p)
end)

exports('SetInventory', function(source, inventory)
  if type(inventory) ~= 'table' then
    return false
  end

  local identifier = Framework:getIdentifier(source)
  Database:saveInventory(identifier, normalizeInventory(inventory))
  TriggerClientEvent('np_inventory:client:syncInventory', source, normalizeInventory(inventory))

  return true
end)

AddEventHandler('onResourceStart', function(resource)
  if resource ~= GetCurrentResourceName() then return end

  Framework:init()
  Database:init()
end)
