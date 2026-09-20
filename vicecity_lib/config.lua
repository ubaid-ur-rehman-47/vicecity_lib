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
    disabled = {},
}
