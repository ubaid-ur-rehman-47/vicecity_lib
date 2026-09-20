fx_version 'cerulean'
game 'gta5'
author 'discord.gg/codesign'
description 'Codesign Bridge'
version '1.2.1'
lua54 'yes'

client_scripts {
    '@cd_bridge/client/init.lua',
    'shared/file_loader.lua',
}

server_scripts {
    '@cd_bridge/server/init.lua',
    'shared/file_loader.lua',
    'server/core/read_directory.js'
}

exports {
    'Callback',
    'RegisterClientCallback',
    'StoreError',
    'GetErrors',
    'FileLoaded',
    'GetPlayerInfo',
}

server_exports {
    'Callback',
    'RegisterServerCallback',
    'StoreError',
    'GetErrors',
    'FileLoaded',
    'ReadDirectory',
}

escrow_ignore {
    'client/**/*.lua',
    'locales/**/*.lua',
    'server/**/*.lua',
    'shared/**/*.lua',
}

ui_page {
    'nui/index.html'
}

files {
    -- lua
    'client/**/*.lua',
    'shared/*.lua',
    'locales/lua/*.lua',
    -- js
    'nui/index.html',
    'nui/js/*.js',
    'nui/images/logos/*.webp',
    'nui/images/vehicles/*.webp'
}
dependency '/assetpacks'