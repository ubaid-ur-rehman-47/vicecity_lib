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
}

client_scripts {
    'client/framework.lua',
    'client/init.lua',
}

server_scripts {
    'server/framework.lua',
    'server/init.lua',
}

export 'GetVersion'
export 'IsReady'
export 'GetProvider'
export 'GetDiagnostics'
export 'RegisterProvider'
export 'GetFramework'

server_export 'GetVersion'
server_export 'IsReady'
server_export 'GetProvider'
server_export 'GetDiagnostics'
server_export 'RegisterProvider'
server_export 'GetFramework'
