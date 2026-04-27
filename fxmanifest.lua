fx_version 'cerulean'

game 'gta5'

lua54 'yes'

author 'np_inventory'
description 'Drag-and-drop ready inventory base with framework and database auto-detection'
version '1.1.0'

ui_page 'web/build/index.html'

shared_script {
  'shared/config.lua',
  'shared/items.lua',
  'shared/animations.lua',
  'shared/crafting.lua',
  'shared/evidence.lua',
  'shared/licenses.lua',
  'shared/shops.lua',
  'shared/stashes.lua',
  'shared/vehicles.lua',
  'shared/weapons.lua',
}

client_scripts {
  'client/utils.lua',
  'client/client.lua',
}

server_scripts {
  'server/framework.lua',
  'server/database.lua',
  'server/server.lua',
}

files {
  'web/build/index.html',
  'web/build/**/*',
}
