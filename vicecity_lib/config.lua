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
    disabled = {},
}
