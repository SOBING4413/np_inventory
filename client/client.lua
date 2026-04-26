local inventoryState = nil
local inventoryContext = {
  type = 'player',
  name = 'player',
}

local function requestInventory(invType, invName)
  inventoryContext.type = invType or 'player'
  inventoryContext.name = invName or 'player'
  TriggerServerEvent('np_inventory:server:requestInventory', inventoryContext.type, inventoryContext.name)
end

local function toggleNuiFrame(shouldShow)
  SetNuiFocus(shouldShow, shouldShow)
  SendReactMessage('setVisible', shouldShow)

  if shouldShow then
    requestInventory(inventoryContext.type, inventoryContext.name)
  else
    TriggerServerEvent('np_inventory:server:saveNamedInventory', inventoryContext.type, inventoryContext.name, inventoryState or {})
  end
end

RegisterCommand('show-nui', function()
  inventoryContext = { type = 'player', name = 'player' }
  toggleNuiFrame(true)
  debugPrint('Show player inventory')
end)

RegisterCommand('show-trunk', function(_, args)
  local plate = args[1] or 'UNKNOWN'
  inventoryContext = { type = 'trunk', name = plate }
  toggleNuiFrame(true)
  debugPrint(('Show trunk inventory: %s'):format(plate))
end)

RegisterCommand('show-stash', function(_, args)
  local stash = args[1] or 'public'
  inventoryContext = { type = 'stash', name = stash }
  toggleNuiFrame(true)
  debugPrint(('Show stash inventory: %s'):format(stash))
end)

RegisterNUICallback('hideFrame', function(_, cb)
  toggleNuiFrame(false)
  debugPrint('Hide NUI frame')
  cb({})
end)

RegisterNUICallback('getClientData', function(data, cb)
  debugPrint('Data sent by React', json.encode(data))

  local curCoords = GetEntityCoords(PlayerPedId())
  local retData <const> = { x = curCoords.x, y = curCoords.y, z = curCoords.z }
  cb(retData)
end)

RegisterNetEvent('np_inventory:client:syncInventory', function(payload)
  if type(payload) == 'table' and payload.inventory then
    inventoryState = payload.inventory
    if type(payload.context) == 'table' then
      inventoryContext.type = payload.context.type or inventoryContext.type
      inventoryContext.name = payload.context.name or inventoryContext.name
    end
  else
    inventoryState = payload
  end

  SendReactMessage('inventory:update', inventoryState)
end)
