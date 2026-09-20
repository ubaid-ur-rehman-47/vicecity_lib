local MissingPreStartItems = {}
local PreStartItemsChecked = {}

AddEventHandler('onResourceStop', function(resource)
    MissingPreStartItems[resource] = nil
    PreStartItemsChecked[resource] = nil
end)

function CheckAllItemsExist(needed, invokingResourceName)
    invokingResourceName = invokingResourceName or GetInvokingResource()
    if Cfg.Inventory == 'none' then
        if invokingResourceName then
            MissingPreStartItems[invokingResourceName] = {}
            PreStartItemsChecked[invokingResourceName] = true
        end
        return {}
    end

    local have = {}
    local items = GetItemList()

    if not items then
        ERROR('0235', 'Inventory items table not available: '..Cfg.Inventory)

        if invokingResourceName then
            MissingPreStartItems[invokingResourceName] = {}
            PreStartItemsChecked[invokingResourceName] = true
        end

        return {}
    end

    for name in pairs(items) do
        if name then have[name] = true end
    end

    local missing = {}

    for _, itemName in pairs(needed) do
        if not have[itemName] then
            missing[#missing + 1] = itemName
        end
    end

    table.sort(missing)

    if invokingResourceName then
        MissingPreStartItems[invokingResourceName] = missing
        PreStartItemsChecked[invokingResourceName] = true
    end

    if #missing > 0 then
        local itemLines = '    - '..table.concat(missing, '\n    - ')
        local resourceLabel = invokingResourceName and ('['..invokingResourceName..'] ') or ''
        ERROR('0657', resourceLabel..Locale('missing_inventory_items', Cfg.Inventory)..'\n\n'..itemLines)
    end

    return missing
end
RegisterServerEvent('cd_bridge:CheckAllItemsExist', CheckAllItemsExist)

function GetMissingPreStartItems(resource)
    while not PreStartItemsChecked[resource] do Wait(100) end
    return MissingPreStartItems[resource] or {}
end
exports('GetMissingPreStartItems', GetMissingPreStartItems)
