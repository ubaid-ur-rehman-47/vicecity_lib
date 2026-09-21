--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not lib then return end

local Items = require 'modules.items.server'
local Inventory = require 'modules.inventory.server'
local TriggerEventHooks = require 'modules.hooks.server'
local Shops = {}
local locations = 'locations'


local function setupShopItems(id, shopType, shopName, groups)
	local shop = id and Shops[shopType][id] or Shops[shopType] --[[@as OxShop]]

	for i = 1, shop.slots do
		local slot = shop.items[i]

		if slot.grade and not groups then
			print(('^1attempted to restrict slot %s (%s) to grade %s, but %s has no job restriction^0'):format(id, slot.name, json.encode(slot.grade), shopName))
			slot.grade = nil
		end

		local Item = Items(slot.name)

		if Item then
			slot = {
				name = Item.name,
				slot = i,
				weight = Item.weight,
				count = slot.count,
				price = (server.randomprices and (not slot.currency or slot.currency == 'money')) and (math.ceil(slot.price * (math.random(80, 120)/100))) or slot.price or 0,
				metadata = slot.metadata,
				license = slot.license,
				currency = slot.currency,
				grade = slot.grade
			}

			if slot.metadata then
				slot.weight = Inventory.SlotWeight(Item, slot, true)
			end

			shop.items[i] = slot
		end
	end
end

local function registerShopType(shopType, properties)
	local shopLocations = properties[locations] or properties.locations

	if shopLocations then
		Shops[shopType] = properties
	else
		Shops[shopType] = {
			label = properties.name,
			id = shopType,
			groups = properties.groups or properties.jobs,
			items = properties.inventory,
			slots = #properties.inventory,
			type = 'shop',
			paymentMethods = properties.paymentMethods,
		}

		setupShopItems(nil, shopType, properties.name, properties.groups or properties.jobs)
	end
end

local function createShop(shopType, id)
	local shop = Shops[shopType]

	if not shop then return end

	local store = (shop[locations] or shop.locations)?[id]

	if not store then return end

	local groups = shop.groups or shop.jobs
	local coords = type(store) == 'vector4' and vec3(store.x, store.y, store.z) or store

	shop[id] = {
		label = shop.name,
		id = shopType..' '..id,
		groups = groups,
		items = table.clone(shop.inventory),
		slots = #shop.inventory,
		type = 'shop',
		coords = coords,
		distance = shop.interact?.dist or 3.0,
		paymentMethods = shop.paymentMethods,
	}

	setupShopItems(id, shopType, shop.name, groups)

	return shop[id]
end

for shopType, shopDetails in pairs(lib.load('data.shops') or {}) do
	registerShopType(shopType, shopDetails)
end

exports('RegisterShop', function(shopType, shopDetails)
	registerShopType(shopType, shopDetails)
end)

lib.callback.register('ox_inventory:openShop', function(source, data)
	local playerInv, shop = Inventory(source)

	if not playerInv then return end

	if data then
		shop = Shops[data.type]

		if not shop then return end

		if not shop.items then
			shop = (data.id and shop[data.id] or createShop(data.type, data.id))

			if not shop then return end
		end


		if shop.groups then
			local group = server.hasGroup(playerInv, shop.groups)
			if not group then return end
		end

		if type(shop.coords) == 'vector3' and #(GetEntityCoords(GetPlayerPed(source)) - shop.coords) > 10 then
			return
		end

		local shopType, shopId = shop.id:match('^(.-) (%d-)$')

        local hookPayload = {
            source = source,
            shopId = shopId,
			shopType = shopType,
            label = shop.label,
            slots = shop.slots,
            items = shop.items,
            groups = shop.groups,
            coords = shop.coords,
            distance = shop.distance
        }

        if not TriggerEventHooks('openShop', hookPayload) then return end

		playerInv:openInventory(playerInv)
		playerInv.currentShop = shop.id
	end

	return { label = playerInv.label, type = playerInv.type, slots = playerInv.slots, weight = playerInv.weight, maxWeight = playerInv.maxWeight }, shop
end)

local function canAffordItem(inv, currency, price)
	local canAfford = price >= 0 and Inventory.GetItemCount(inv, currency) >= price

	return canAfford or {
		type = 'error',
		description = locale('cannot_afford', ('%s%s'):format((currency == 'money' and locale('$') or math.groupdigits(price)), (currency == 'money' and math.groupdigits(price) or ' '..Items(currency).label)))
	}
end

local function removeCurrency(inv, currency, price)
	Inventory.RemoveItem(inv, currency, price)
end

local function isRequiredGrade(grade, rank)
	if type(grade) == "table" then
		for i=1, #grade do
			if grade[i] == rank then
				return true
			end
		end
		return false
	else
		return rank >= grade
	end
end

lib.callback.register('ox_inventory:buyItem', function(source, data)
	if data.toType == 'player' then
		if data.count == nil then data.count = 1 end

		local playerInv = Inventory(source)

		if not playerInv or not playerInv.currentShop then return end

		local shopType, shopId = playerInv.currentShop:match('^(.-) (%d-)$')

		if not shopType then shopType = playerInv.currentShop end

		if shopId then shopId = tonumber(shopId) end

		local shop = shopId and Shops[shopType][shopId] or Shops[shopType]
		local fromData = shop.items[data.fromSlot]
		local toData = playerInv.items[data.toSlot]

		if fromData then
			if fromData.count then
				if fromData.count == 0 then
					return false, false, { type = 'error', description = locale('shop_nostock') }
				elseif data.count > fromData.count then
					data.count = fromData.count
				end
			end

			if fromData.license and server.hasLicense and not server.hasLicense(playerInv, fromData.license) then
				return false, false, { type = 'error', description = locale('item_unlicensed') }
			end

			if fromData.grade then
				local _, rank = server.hasGroup(playerInv, shop.groups)
				if not isRequiredGrade(fromData.grade, rank) then
					return false, false, { type = 'error', description = locale('stash_lowgrade') }
				end
			end

			local currency = fromData.currency or data.paymentMethod or 'money'

			if shop.paymentMethods then
				local isValidMethod = false

				for i = 1, #shop.paymentMethods do
					if shop.paymentMethods[i] == currency then
						isValidMethod = true
						break
					end
				end

				if not isValidMethod then
					currency = shop.paymentMethods[1] or 'money'
				end
			end
			local fromItem = Items(fromData.name)

			local result = fromItem.cb and fromItem.cb('buying', fromItem, playerInv, data.fromSlot, shop)
			if result == false then return false end

			local toItem = toData and Items(toData.name)

			local metadata, count = Items.Metadata(playerInv, fromItem, fromData.metadata and table.clone(fromData.metadata) or {}, data.count)
			local price = count * fromData.price

			if toData == nil or (fromItem.name == toItem?.name and fromItem.stack and table.matches(toData.metadata, metadata)) then
				local newWeight = playerInv.weight + (fromItem.weight + (metadata?.weight or 0)) * count

				if newWeight > playerInv.maxWeight then
					return false, false, { type = 'error', description = locale('cannot_carry') }
				end

				local canAfford = canAffordItem(playerInv, currency, price)

				if canAfford ~= true then
					return false, false, canAfford
				end

				if not TriggerEventHooks('buyItem', {
					source = source,
					shopType = shopType,
					shopId = shopId,
					toInventory = playerInv.id,
					toSlot = data.toSlot,
					fromSlot = fromData,
					itemName = fromData.name,
					metadata = metadata,
					count = count,
					price = fromData.price,
					totalPrice = price,
					currency = currency,
				}) then return false end

				Inventory.SetSlot(playerInv, fromItem, count, metadata, data.toSlot)
				playerInv.weight = newWeight
				removeCurrency(playerInv, currency, price)

				if fromData.count then
					shop.items[data.fromSlot].count = fromData.count - count
				end

				if server.syncInventory then server.syncInventory(playerInv) end

				local message = locale('purchased_for', count, metadata?.label or fromItem.label, (currency == 'money' and locale('$') or math.groupdigits(price)), (currency == 'money' and math.groupdigits(price) or ' '..Items(currency).label))

				if server.loglevel > 0 then
					if server.loglevel > 1 or fromData.price >= 500 then
						lib.logger(playerInv.owner, 'buyItem', ('"%s" %s'):format(playerInv.label, message:lower()), ('shop:%s'):format(shop.label))
					end
				end

				return true, {data.toSlot, playerInv.items[data.toSlot], shop.items[data.fromSlot].count and shop.items[data.fromSlot], playerInv.weight}, { type = 'success', description = message }
			end

			return false, false, { type = 'error', description = locale('unable_stack_items') }
		end
	end
end)

server.shops = Shops

lib.callback.register('ox_inventory:buyCart', function(source, data)
    local playerInv = Inventory(source)
    if not playerInv or not playerInv.currentShop then return false end

    local shopType, shopId = playerInv.currentShop:match('^(.-) (%d-)$')
    if not shopType then shopType = playerInv.currentShop end
    if shopId then shopId = tonumber(shopId) end

    local shop = shopId and Shops[shopType][shopId] or Shops[shopType]
    if not shop then return false end

    local currency = data.payment or 'money'
    if shop.paymentMethods then
        local isValidMethod = false
        for i = 1, #shop.paymentMethods do
            if shop.paymentMethods[i] == currency then
                isValidMethod = true
                break
            end
        end
        if not isValidMethod then
            currency = shop.paymentMethods[1] or 'money'
        end
    end

    local totalPrice = 0
    local totalWeight = 0
    local itemsToGive = {}

    for _, itemData in ipairs(data.items) do
        local fromData = shop.items[itemData.slot]
        if not fromData then return false end

        local count = itemData.count or 1
        if fromData.count then
            if fromData.count == 0 then
                return false
            elseif count > fromData.count then
                count = fromData.count
            end
        end

        if fromData.license and server.hasLicense and not server.hasLicense(playerInv, fromData.license) then
            return false
        end

        if fromData.grade then
            local _, rank = server.hasGroup(playerInv, shop.groups)
            if not isRequiredGrade(fromData.grade, rank) then
                return false
            end
        end

        local fromItem = Items(fromData.name)
        local metadata, finalCount = Items.Metadata(playerInv, fromItem, fromData.metadata and table.clone(fromData.metadata) or {}, count)
        local price = finalCount * fromData.price

        totalPrice = totalPrice + price
        totalWeight = totalWeight + (fromItem.weight + (metadata and metadata.weight or 0)) * finalCount

        table.insert(itemsToGive, {
            name = fromData.name,
            count = finalCount,
            metadata = metadata,
            price = price,
            fromSlot = itemData.slot,
            fromDataCount = fromData.count
        })
    end

    if playerInv.weight + totalWeight > playerInv.maxWeight then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('cannot_carry') })
        return false
    end

    local canAfford = canAffordItem(playerInv, currency, totalPrice)
    if canAfford ~= true then
        TriggerClientEvent('ox_lib:notify', source, canAfford)
        return false
    end

    for _, item in ipairs(itemsToGive) do
        local success, response = Inventory.AddItem(playerInv, item.name, item.count, item.metadata)
        if success then
            if item.fromDataCount then
                shop.items[item.fromSlot].count = item.fromDataCount - item.count
            end
        end
    end

    removeCurrency(playerInv, currency, totalPrice)
    
    local message = locale('purchased_for', #data.items, locale('ui_item_plural') or 'items', (currency == 'money' and locale('$') or math.groupdigits(totalPrice)), (currency == 'money' and math.groupdigits(totalPrice) or ' '..Items(currency).label))
    TriggerClientEvent('ox_lib:notify', source, { type = 'success', description = message })

    if server.loglevel > 0 then
        lib.logger(playerInv.owner, 'buyCart', ('"%s" %s'):format(playerInv.label, message:lower()), ('shop:%s'):format(shop.label))
    end

    return { success = true }
end)
