fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'vicecity_lib'
author 'ViceCity'
description 'Configurable FiveM compatibility and utility library'
version '0.1.0'

shared_scripts {
    'config.lua',
    'shared/runtime.lua',
    'shared/framework.lua',
    'shared/inventory.lua',
    'shared/appearance.lua',
}

client_scripts {
    'client/framework.lua',
    'client/inventory/*.lua',
    'client/appearance/*.lua',
    'client/appearance.lua',
    'client/init.lua',
}

server_scripts {
    'server/framework.lua',
    'server/inventory/*.lua',
    'server/appearance/*.lua',
    'server/appearance.lua',
    'server/init.lua',
}

export 'GetVersion'
export 'IsReady'
export 'GetProvider'
export 'GetDiagnostics'
export 'RegisterProvider'
export 'GetFramework'
export 'GetAppearance'
export 'SetAppearance'
export 'OpenWardrobe'

server_export 'GetVersion'
server_export 'IsReady'
server_export 'GetProvider'
server_export 'GetDiagnostics'
server_export 'RegisterProvider'
server_export 'GetFramework'
server_export 'GetAppearance'
server_export 'SetAppearance'
server_export 'OpenWardrobe'
