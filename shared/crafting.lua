Config = Config or {}

Config.Crafting = {
  benches = {
    public = {
      label = 'Public Workbench',
      jobs = nil,
      recipes = { 'lockpick' },
    },
  },
  recipes = {
    lockpick = {
      label = 'Lockpick',
      duration = 5000,
      result = { name = 'lockpick', count = 1 },
      ingredients = {
        { name = 'bread', count = 1 },
        { name = 'water', count = 1 },
      },
    },
  },
}
