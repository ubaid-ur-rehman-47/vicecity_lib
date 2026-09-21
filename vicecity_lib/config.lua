ViceCityConfig = {
    debug = false,
    strict = false,
    providerTimeout = 5000,
    providers = {
        framework = 'auto',
        inventory = 'auto',
        database = 'auto',
    },
    frameworkPriority = { 'qbox', 'qb', 'esx', 'standalone' },
    inventoryPriority = {
        'ox', 'qb', 'qs', 'codem', 'codemv2', 'core', 'tgiann',
        'origen', 'ak47', 'ak47qb', 'jaksam', 'jpr', 'ps', 'lj', 'esx', 's', 'native',
    },
    appearance = {
        provider = 'auto',
        priority = {
            '17mov', 'codem', 'codemAppearance', 'illenium', 'qb', 'esx', 'skinchanger',
            'fivem', 'qs', '4bit', 'qf', 'crm', 'tgiann', 'rcore', '0r', 'native',
        },
        applyMode = 'hybrid',
    },
    phone = {
        provider = 'quasar_v3',
        priority = {
            'quasar_pro', 'quasar_v3', 'lb', 'codem', '17mov', 'gcphone',
            'gksphone', 'high', 'npwd', 'yseries', 'roadphone', 'sd', 'framework',
        },
        minDigits = 3,
        maxDigits = 15,
        generateDigits = 7,
    },
    banking = {
        provider = 'auto',
        priority = {
            'okokbanking', 'qb-banking', 'renewed', 'fd_banking', 'tgg-banking',
            'tgiann-bank', 'qs-banking', 'wasabi', 'snipe', 'crm-banking',
            'kartik', 'p_banking', 'nfs-banking', 'nfs-billing', 'RxBanking',
            'sd-multijob', 'vms_bossmenu', 'nass_bossmenu', 'xnr-bossmenu',
            'esx_society', 'qb-management', 'framework',
        },
        sqlFallback = nil,
    },
    garage = {
        provider = 'auto',
        priority = { 'qbx_garages', 'qb-garages', 'cd_garage', 'qs-advancedgarages' },
    },
    vehicleKeys = {
        provider = 'auto',
        priority = {
            'qbx_vehiclekeys', 'qb-vehiclekeys', 'wasabi_carlock', 'Renewed-Vehiclekeys', 'MrNewbVehicleKeys',
            'vehicles_keys', 'tgiann-hotwire', 'mVehicle', 'okokGarage', 'cd_garage', 'ND_Core',
            '0r-vehiclekeys', 'LifeSaver_KeySystem', 'ak47_qb_vehiclekeys', 'ak47_vehiclekeys', 'qs-vehiclekeys',
            'native',
        },
        -- tgiann-hotwire is a separate ignition layer: when installed alongside
        -- another key provider, also put a key in the ignition on give.
        hotwireIgnition = true,
    },
    vehicles = {
        -- Persistence is provider-owned (the active garage adapter's own
        -- vehicle table) unless an explicit SQL mapping is declared here, e.g.
        -- sqlFallback = { table = 'player_vehicles', plateColumn = 'plate',
        --     identifierColumn = 'citizenid', modelColumn = 'vehicle', garageColumn = 'garage',
        --     stateColumn = 'state', propsColumn = 'mods', engineColumn = 'engine',
        --     bodyColumn = 'body', fuelColumn = 'fuel' },
        sqlFallback = nil,
    },
    disabled = {},
}
