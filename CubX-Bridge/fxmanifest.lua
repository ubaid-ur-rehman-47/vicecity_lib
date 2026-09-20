--  ____    _    _   _ _   _
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

fx_version 'cerulean'
game 'gta5'

name 'CubX-Bridge'
author 'CBUX'
description 'Multi-framework bridge for ESX, QB-Core, and QBox compatibility'
version '1.0.0'

lua54 'yes'

dependencies {
    'qbx_core',
    'ox_lib',
}

shared_scripts {
    'config.lua',
    'shared/utils.lua',
    'shared/init.lua',

    'modules/frameworks/*.lua',
    'modules/inventories/*.lua',
    'modules/appearances/*.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua',
    'client/framework.lua',
    'client/player.lua',
    'client/callbacks.lua',
    'client/inventory.lua',
    'client/notifications.lua',
    'client/progressbar.lua',
    'client/ui.lua',
    'client/appearance.lua',
}

files {
    'shared/data/*.lua',
}

escrow_ignore {
    'config.lua',
}
