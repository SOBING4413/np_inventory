local inventoryState = nil

local function toggleNuiFrame(shouldShow)
  SetNuiFocus(shouldShow, shouldShow)
  SendReactMessage('setVisible', shouldShow)

  if shouldShow then
    TriggerServerEvent('np_inventory:server:saveInventory', inventoryState or {})
  end
end

RegisterCommand('show-nui', function()
  toggleNuiFrame(true)
  debugPrint('Show NUI frame')
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
  inventoryState = payload
  SendReactMessage('inventory:update', payload)
end)
