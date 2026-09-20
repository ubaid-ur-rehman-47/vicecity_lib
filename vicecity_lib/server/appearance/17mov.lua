local provider = {
    name = '17mov',
    resource = '17mov_CharacterSystem',
    capabilities = {
        persistence = false,
        playerAppearance = false,
        wardrobeEvents = true,
    },
}

function provider:get() return false, { reason = 'client_only', operation = 'get', provider = self.name } end

function provider:set(source) return false, { reason = 'client_only', operation = 'set', source = source } end

function provider:save() return false,
        { reason = 'provider_owned_client_event', operation = 'save', provider = self.name } end

function provider:load() return false, { reason = 'client_only', operation = 'load', provider = self.name } end

function provider:openWardrobe(source)
    if source then TriggerClientEvent('17mov_CharacterSystem:OpenOutfitsMenu', source) end
    return source ~= nil
end

ViceCity.RegisterProvider('appearance', '17mov', provider)
