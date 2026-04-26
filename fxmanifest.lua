fx_version 'cerulean'

game 'gta5'

lua54 'yes'

author 'np_inventory'
description 'Drag-and-drop ready inventory base with framework and database auto-detection'
version '1.1.0'

ui_page 'web/build/index.html'

shared_script {
  'shared/config.lua',
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
