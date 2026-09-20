local found = GetResourceState('tgiann-inventory')
if found ~= 'started' and found ~= 'starting' then return end

nass.inventorySystem = 'tgiann-inventory'
nass.inventory = {}

local registeredShops = {}
RegisterNetEvent('nass_lib:registerShop', function(data)
    local src = source
    if registeredShops[data.identifier] then
       exports["tgiann-inventory"]:OpenInventory(src, 'shop', data.identifier, data.identifier)
        return
    end

    exports["tgiann-inventory"]:RegisterShop(data.identifier,data.inventory)
    registeredShops[data.identifier] = data
    exports["tgiann-inventory"]:OpenInventory(src, 'shop', data.identifier, data.identifier)
end)

function nass.inventory.getItemSlot(source, itemName)
    return GetItemSlot(source, itemName) or false
end

function nass.inventory.getItemMetadata(source, slot)
    if not source or not slot then return end
    return exports["tgiann-inventory"]:GetItemBySlot(source, slot).metadata
end

function nass.inventory.setItemMetadata(source, slot, metadata)
    if not slot then return false end
    if not metadata then metadata = {} end
    local item = exports["tgiann-inventory"]:GetItemBySlot(source, slot)
    exports["tgiann-inventory"]:UpdateItemMetadata(source, item.name, slot, metadata)
end

local function isInList(item, list)
    for _, value in ipairs(list) do
        if value == item then
            return true
        end
    end
    return false
end

---Clears specified inventory
---@param source number
---@param keepItems string | table
function nass.inventory.clearInventory(source, identifier, keepItems)
    exports["tgiann-inventory"]:ClearInventory(source)

    local invData = exports["tgiann-inventory"]:GetPlayerItems(source)
    for _, item in pairs(invData) do
        if item.count > 0 and not isInList(item.name, keepItems) then
            exports["tgiann-inventory"]:RemoveItem(source, item.name, item.count, item.key)
        end
    end
end