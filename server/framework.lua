Framework = {
  name = 'standalone',
  object = nil,
}

local function isStarted(resource)
  return GetResourceState(resource) == 'started'
end

local function detectFramework()
  if Config.Framework ~= 'auto' then
    return Config.Framework
  end

  for name, resources in pairs(Config.FrameworkResources) do
    for _, resource in ipairs(resources) do
      if isStarted(resource) then
        return name
      end
    end
  end

  return 'standalone'
end

function Framework:init()
  self.name = detectFramework()

  if self.name == 'qbcore' and isStarted('qb-core') then
    self.object = exports['qb-core']:GetCoreObject()
  elseif self.name == 'esx' and isStarted('es_extended') then
    self.object = exports['es_extended']:getSharedObject()
  end

  print(('[%s] Framework: %s'):format(GetCurrentResourceName(), self.name))
end

function Framework:getIdentifier(source)
  if self.name == 'qbcore' and self.object then
    local player = self.object.Functions.GetPlayer(source)
    if player and player.PlayerData and player.PlayerData.citizenid then
      return ('qb:%s'):format(player.PlayerData.citizenid)
    end
  elseif self.name == 'esx' and self.object then
    local xPlayer = self.object.GetPlayerFromId(source)
    if xPlayer and xPlayer.identifier then
      return ('esx:%s'):format(xPlayer.identifier)
    end
  elseif self.name == 'qbox' and isStarted('qbx_core') then
    local ok, player = pcall(function()
      return exports.qbx_core:GetPlayer(source)
    end)
    if ok and player and player.PlayerData and player.PlayerData.citizenid then
      return ('qbox:%s'):format(player.PlayerData.citizenid)
    end
  elseif self.name == 'ox_core' and isStarted('ox_core') then
    local ok, player = pcall(function()
      return exports.ox_core:GetPlayer(source)
    end)

    if ok and player then
      if player.charId then
        return ('ox:%s'):format(player.charId)
      end
      if player.stateId then
        return ('ox:%s'):format(player.stateId)
      end
    end
  end

  for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
    if identifier:find('license:') == 1 then
      return identifier
    end
  end

  return ('src:%s'):format(source)
end
