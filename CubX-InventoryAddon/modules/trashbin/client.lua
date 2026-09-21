--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not lib then return end
if GetResourceState("ox_target") ~= "started" then return end

local Trashbin = {}
local validModels = {}

for _, config in pairs(CubXTrashbinsConfig) do
    for _, model in ipairs(config.models) do
        validModels[joaat(model)] = config
    end
end

function Trashbin.open(entity)
    if cache.vehicle then return end
    
    local coords = GetEntityCoords(entity)
    local model = GetEntityModel(entity)
    
    local stashId = lib.callback.await("cubx_inventory:openTrashbin", false, model, coords)
    if stashId then
        exports.ox_inventory:openInventory("stash", stashId)
    end
end

exports.ox_target:addGlobalObject({
    {
        name = "cubx_inventory:trashbin",
        icon = "fas fa-dumpster",
        distance = 2.0,
        canInteract = function(entity)
            return validModels[GetEntityModel(entity)] ~= nil
        end,
        label = function(entity)
            local modelConfig = validModels[GetEntityModel(entity)]
            if modelConfig then
                local label = string.lower(modelConfig.label)
                local formatted = string.format("Search %s", label)
                if formatted then return formatted end
            end
            return "Search trash"
        end,
        onSelect = function(data)
            Trashbin.open(data.entity)
        end
    }
})

return Trashbin