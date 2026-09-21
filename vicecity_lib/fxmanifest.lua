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
    'shared/commands.lua',
    'shared/framework.lua',
    'shared/inventory.lua',
    'shared/appearance.lua',
    'shared/appearance_defaults.lua',
    'shared/phone.lua',
    'shared/banking.lua',
    'shared/garage.lua',
    'shared/vehiclekeys.lua',
    'shared/vehicles.lua',
    'shared/database.lua',
}

client_scripts {
    'client/framework.lua',
    'client/inventory/*.lua',
    'client/appearance/*.lua',
    'client/appearance.lua',
    'client/phone/*.lua',
    'client/phone.lua',
    'client/banking/*.lua',
    'client/banking.lua',
    'client/banking_init.lua',
    'client/garage/*.lua',
    'client/garage.lua',
    'client/vehiclekeys/*.lua',
    'client/vehiclekeys.lua',
    'client/keybinds.lua',
    'client/vehicles_keybinds.lua',
    'client/init.lua',
}

server_scripts {
    'server/framework.lua',
    'server/inventory/*.lua',
    'server/appearance/*.lua',
    'server/appearance.lua',
    'server/phone/*.lua',
    'server/phone.lua',
    'server/banking/*.lua',
    'server/banking.lua',
    'server/society.lua',
    'server/banking_init.lua',
    'server/garage/*.lua',
    'server/garage.lua',
    'server/vehiclekeys/*.lua',
    'server/vehiclekeys.lua',
    'server/vehicles.lua',
    'server/vehicles_commands.lua',
    'server/database/*.lua',
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
export 'GetAppearanceComponent'
export 'SetAppearanceComponent'
export 'GetAppearanceProp'
export 'SetAppearanceProp'
export 'GetDefaultAppearanceComponent'
export 'GetDefaultAppearanceProp'
export 'GetPhoneNumber'
export 'SetPhoneNumber'
export 'GetPhoneProvider'
export 'GetPhoneCapabilities'
export 'GetGarageProvider'
export 'GetGarageCapabilities'
export 'GetVehicleKeysProvider'
export 'GetVehicleKeysCapabilities'
export 'GiveVehicleKeys'
export 'RemoveVehicleKeys'

server_export 'GetVersion'
server_export 'IsReady'
server_export 'GetProvider'
server_export 'GetDiagnostics'
server_export 'RegisterProvider'
server_export 'GetFramework'
server_export 'GetAppearance'
server_export 'SetAppearance'
server_export 'OpenWardrobe'
server_export 'GetPhoneNumber'
server_export 'SetPhoneNumber'
server_export 'GetPhoneProvider'
server_export 'GetPhoneCapabilities'
server_export 'GetGarageProvider'
server_export 'GetGarageCapabilities'
server_export 'GetVehicleKeysProvider'
server_export 'GetVehicleKeysCapabilities'
server_export 'GiveVehicleKeys'
server_export 'RemoveVehicleKeys'
server_export 'CreateVehicle'
server_export 'DeleteVehicle'
server_export 'GetVehicle'
server_export 'ListVehicles'
server_export 'ListOwnedVehicles'
server_export 'CountVehicles'
server_export 'IsVehicleOwnedBy'
server_export 'SetVehicleOwner'
server_export 'SetVehicleGarage'
server_export 'SetVehicleState'
server_export 'SaveVehicleProperties'
server_export 'RepairVehicle'
