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
name 'CubX-InventoryAddon'
description 'CubX custom modules over ox_inventory (clothing, throw, ped preview, weapon customization)'
author 'CubX'
version '1.0.0'

dependencies {
    'ox_inventory',
    'oxmysql',
    'ox_lib',
    'ox_target',
    'CubX-Bridge',
}

shared_script '@ox_lib/init.lua'

ox_libs {
    'locale',
    'table',
    'math',
}

files {
    'locales/*.json',
}

locale 'en'

shared_scripts {
    'data/config.lua',
    'data/throw.lua',
    'data/clothing.lua',
    'data/clothings.lua',
    'data/weaponback.lua',
    'data/trashbins.lua',
}

client_scripts {
    'modules/cloneped/client.lua',
    'modules/throw/client.lua',
    'modules/appearance/client.lua',
    'modules/weaponcustomization/client.lua',
    'modules/weaponback/client.lua',
    'modules/trashbin/client.lua',
    'client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'modules/mysql/server.lua',
    'modules/appearance/server.lua',
    'modules/throw/server.lua',
    'modules/rename/server.lua',
    'modules/weaponback/server.lua',
    'modules/permanent/server.lua',
    'modules/trashbin/server.lua',
    'server.lua',
}

escrow_ignore {
    'data/*.lua',
}