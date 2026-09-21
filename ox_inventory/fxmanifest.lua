--  ____    _    _   _ _   _
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'
name 'ox_inventory'
author 'Overextended'
version '2.44.1'
repository 'https://github.com/overextended/ox_inventory'
description 'Slot-based inventory with item metadata support'

dependencies {
    '/server:6116',
    '/onesync',
    'oxmysql',
    'ox_lib',
    'vicecity_lib',
}

shared_script '@ox_lib/init.lua'

ox_libs {
    'locale',
    'table',
    'math',
}

locale 'en'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'init.lua'
}

client_script 'init.lua'

ui_page 'web/build/index.html'

files {
    'client.lua',
    'server.lua',
    'locales/*.json',
    'web/build/index.html',
    'web/build/assets/*.js',
    'web/build/assets/*.css',
    'web/images/*.png',
    'web/images/icons/*.svg',
    'web/images/clothing/slot/*.png',
    'modules/**/shared.lua',
    'modules/**/client.lua',
    'modules/**/server.lua',
    'modules/bridge/**/client.lua',
    'modules/bridge/**/server.lua',
    'modules/items/containers.lua',
    'data/*.lua',
}

escrow_ignore {
    'init.lua',
    'client.lua',
    'server.lua',
    'locales/*.json',
    'data/**/*',
    'setup/**/*',
    'modules/bridge/**/*',
    'modules/crafting/**/*',
    'modules/hooks/**/*',
    'modules/interface/**/*',
    'modules/inventory/**/*',
    'modules/items/**/*',
    'modules/mysql/**/*',
    'modules/pefcl/**/*',
    'modules/shops/**/*',
    'modules/utils/**/*',
    'modules/weapon/**/*',
}
