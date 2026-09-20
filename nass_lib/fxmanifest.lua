-- =========================================
-- Decrypted & Cleaned by AK Members
-- =========================================
version '1.3.3' -- Use this script version when making a ticket

use_experimental_fxv2_oal 'yes'
game 'gta5'
lua54 'yes'

description 'nass_lib'
author 'Nass Scripts'


shared_scripts { 'config.lua', 'utils/shared.lua', }

client_scripts {    
  '@ox_lib/init.lua', 
  'utils/**/client.lua',
  'frameworks/**/client.lua',
  'inventories/**/client.lua',
  'targets/*.lua',
  'overrides/**/client.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'utils/**/server.lua',
  'frameworks/**/server.lua',
  'inventories/**/server.lua',
  'overrides/**/server.lua',
}

escrow_ignore {
  'config.lua',
  'frameworks/**',
  'targets/**',
  'utils/**',
  'inventories/**',
  'overrides/**',
}

files {
  'import.lua',
}

dependencies {
	'ox_lib',
}

fx_version 'cerulean' -- This is NOT the script version when making a ticket
