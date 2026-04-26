Config = {}

-- auto | qbcore | esx | ox_core | qbox | standalone
Config.Framework = 'auto'

-- auto | oxmysql | mysql-async | memory
Config.Database = 'auto'

Config.Debug = GetConvarInt(('%s-debugMode'):format(GetCurrentResourceName()), 0) == 1
Config.DefaultSlots = 40
Config.DefaultMaxWeight = 120000 -- grams

Config.FrameworkResources = {
  qbcore = { 'qb-core' },
  esx = { 'es_extended' },
  ox_core = { 'ox_core' },
  qbox = { 'qbx_core' },
}
