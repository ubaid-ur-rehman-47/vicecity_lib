local provider = {
    name = 'native',
    capabilities = {
        persistence = false,
        playerAppearance = false,
    },
}

function provider:get() return false, { reason = 'client_only', operation = 'get', provider = self.name } end

function provider:set() return false, { reason = 'client_only', operation = 'set', provider = self.name } end

function provider:save() return false, { reason = 'unsupported', operation = 'save', provider = self.name } end

function provider:load() return false, { reason = 'unsupported', operation = 'load', provider = self.name } end

function provider:openWardrobe() return false,
        { reason = 'client_only', operation = 'openWardrobe', provider = self.name } end

ViceCity.RegisterProvider('appearance', 'native', provider)
