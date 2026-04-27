Config = Config or {}

Config.Items = {
  water = {
    label = 'Water Bottle',
    weight = 500,
    stack = true,
    close = true,
    description = 'Air mineral segar.',
    image = 'water.svg',
  },
  bread = {
    label = 'Bread',
    weight = 300,
    stack = true,
    close = true,
    description = 'Roti untuk mengisi lapar.',
    image = 'bread.svg',
  },
  phone = {
    label = 'Phone',
    weight = 700,
    stack = false,
    close = true,
    description = 'Smartphone pribadi.',
    image = 'phone.svg',
  },
  lockpick = {
    label = 'Lockpick',
    weight = 150,
    stack = true,
    close = true,
    description = 'Alat pembuka kunci.',
    image = 'lockpick.svg',
  },
  pistol = {
    label = 'Pistol',
    weight = 1800,
    stack = false,
    close = true,
    description = 'Senjata api ringan.',
    image = 'pistol.svg',
  },
}

function GetItemDefinition(name)
  if not name then return nil end
  return Config.Items[tostring(name)]
end
