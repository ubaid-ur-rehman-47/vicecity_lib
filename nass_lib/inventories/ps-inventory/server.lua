-- Use this file to add support for another inventory by simply copying the file and replacing the logic within the functions
local found = GetResourceState('ps-inventory')
if found ~= 'started' and found ~= 'starting' then return end

nass.inventory = {}
nass.inventorySystem = 'ps-inventory'

OldInventory = GetResourceMetadata(nass.inventorySystem, 'version', 0)
OldInventory = OldInventory:gsub('%.', '')
OldInventory = tonumber(OldInventory)
if not OldInventory or OldInventory >= 105 then OldInventory = false end

if not OldInventory then
    local registeredShops = {}
    RegisterNetEvent('nass_lib:registerShop', function(data)
        local src = source
        if registeredShops[data.identifier] then
            exports['ps-inventory']:OpenShop(src, data.identifier)
            return
        end

        exports['ps-inventory']:CreateShop({
            name = data.identifier,
            label = data.name,
            slots = #data.inventory,
            items = data.inventory -- { name = 'sandwich', price = 5 }
        })
        registeredShops[data.identifier] = data
        exports['ps-inventory']:OpenShop(src, data.identifier)
    end)

    RegisterNetEvent('nass_lib:openStash', function(data)
        local src = source
        exports['ps-inventory']:OpenInventory(src, data.name,
            { label = data.name, slots = data.slots, maxweight = data.maxWeight })
    end)

    RegisterNetEvent('nass_lib:openPlayerInventory', function(targetId)
        local src = source
        exports['ps-inventory']:OpenInventoryById(src, targetId)
    end)
end


function nass.inventory.getItemSlot(source, itemName)
    return GetItemSlot(source, itemName) or false
end

function nass.inventory.getItemMetadata(source, slot)
    local player = nass.getPlayer(source)
    if not player then return end
    return player.Functions.GetItemBySlot(slot).info
end

function nass.inventory.setItemMetadata(source, slot, metadata)
    if not slot then return false end
    local player = nass.getPlayer(source)
    if not player then return end
    local item = player.Functions.GetItemBySlot(slot)
    if not item then return false end
    item.info = metadata
    player.PlayerData.items[slot] = item
    player.Functions.SetPlayerData("items", player.PlayerData.items)
    return true
end

---Clears specified inventory
---@param source number
---@param keepItems string | table
function nass.inventory.clearInventory(source, identifier, keepItems)
    exports['ps-inventory']:ClearInventory(source, keepItems)
end