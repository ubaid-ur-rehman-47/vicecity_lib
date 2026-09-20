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
    disabled = {},
}
