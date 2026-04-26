Config = {}

-- auto | qbcore | esx | ox_core | qbox | standalone
Config.Framework = 'auto'

-- auto | oxmysql | mysql-async | memory
Config.Database = 'auto'

Config.Debug = GetConvarInt(('%s-debugMode'):format(GetCurrentResourceName()), 0) == 1

Config.InventoryProfiles = {
  player = {
    slots = 40,
    maxWeight = 120000,
  },
  trunk = {
    slots = 80,
    maxWeight = 250000,
  },
  glovebox = {
    slots = 15,
    maxWeight = 30000,
  },
  stash = {
    slots = 80,
    maxWeight = 250000,
  },
  drop = {
    slots = 30,
    maxWeight = 60000,
  },
}

-- Legacy aliases
Config.DefaultSlots = Config.InventoryProfiles.player.slots
Config.DefaultMaxWeight = Config.InventoryProfiles.player.maxWeight

Config.FrameworkResources = {
  qbcore = { 'qb-core' },
  esx = { 'es_extended' },
  ox_core = { 'ox_core' },
  qbox = { 'qbx_core' },
}
