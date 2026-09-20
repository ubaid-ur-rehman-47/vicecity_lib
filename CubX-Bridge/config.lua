--  ____    _    _   _ _   _
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox
--[[
    CBUX Bridge Configuration
    Multi-framework compatibility layer for FiveM scripts
]]

Config = {}

Config.Framework = nil

Config.Inventory = nil

Config.Appearance = nil

Config.Debug = false

Config.MoneyTypes = {
    cash = {
        esx = 'money',
        qbcore = 'cash',
        qbox = 'cash'
    },
    bank = {
        esx = 'bank',
        qbcore = 'bank',
        qbox = 'bank'
    },
    crypto = {
        esx = 'black_money',
        qbcore = 'crypto',
        qbox = 'crypto'
    },
    dirty = {
        esx = 'black_money',
        qbcore = 'crypto',
        qbox = 'crypto'
    }
}

Config.DefaultMetadata = {
    hunger = 100,
    thirst = 100,
    stress = 0,
    armor = 0,
    isHandcuffed = false,
    isDead = false,
    inJail = false,
    phoneNumber = nil,
    bloodtype = 'Unknown',
}

Config.Notifications = {
    useOxLib = true,
    defaultDuration = 5000,
    textUIPosition = 'right-center',
}

Config.Progressbar = {
    useOxLib = true,
}

Config.GangSystem = {
    enabled = false,
    tableName = 'cbux_player_gangs',
}

Config.CallbackTimeout = 10000

Config.Cache = {
    playerData = true,
    refreshInterval = 0,
}

Config.ResourceNames = {
    esx = 'es_extended',
    qbcore = 'qb-core',
    qbox = 'qbx_core',
    ox_inventory = 'ox_inventory',
    qb_inventory = 'qb-inventory',
    qs_inventory = 'qs-inventory',
    esx_inventory = 'esx_inventory',
    codem_inventory = 'codem-inventory',
    ox_lib = 'ox_lib',
    illenium_appearance = 'illenium-appearance',
    qb_clothing = 'qb-clothing',
    esx_skin = 'esx_skin',
}

Config.EventPrefix = 'cbux'

Config.Locale = 'en'

Config.Locales = {
    en = {
        bridge_ready = 'CBUX Bridge initialized',
        framework_detected = 'Framework detected: %s',
        inventory_detected = 'Inventory detected: %s',
        no_framework = 'No compatible framework found!',
        player_not_found = 'Player not found',
        insufficient_funds = 'Insufficient funds',
        item_added = 'Received %dx %s',
        item_removed = 'Removed %dx %s',
        cannot_carry = 'Cannot carry this item',
        appearance_detected = 'Appearance system detected: %s',
    },
    fr = {
        bridge_ready = 'CBUX Bridge initialise',
        framework_detected = 'Framework detecte: %s',
        inventory_detected = 'Inventaire detecte: %s',
        no_framework = 'Aucun framework compatible trouve!',
        player_not_found = 'Joueur introuvable',
        insufficient_funds = 'Fonds insuffisants',
        item_added = 'Recu %dx %s',
        item_removed = 'Retire %dx %s',
        cannot_carry = 'Impossible de porter cet objet',
        appearance_detected = 'Systeme d\'apparence detecte: %s',
    }
}

function Config.Translate(key, ...)
    local locale = Config.Locales[Config.Locale] or Config.Locales['en']
    local str = locale[key] or key
    if ... then
        return string.format(str, ...)
    end
    return str
end
