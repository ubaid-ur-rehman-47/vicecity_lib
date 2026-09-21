--  ____    _    _   _ _   _
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not lib then return end

local Items = require 'modules.items.shared' --[[@as table<string, OxClientItem>]]

local function sendDisplayMetadata(data)
	SendNUIMessage({
		action = 'displayMetadata',
		data = data
	})
end

local function displayMetadata(metadata, value)
	local data = {}

	if type(metadata) == 'string' then
		if not value then return end

		data = { { metadata = metadata, value = value } }
	elseif table.type(metadata) == 'array' then
		for i = 1, #metadata do
			for k, v in pairs(metadata[i]) do
				data[i] = {
					metadata = k,
					value = v,
				}
			end
		end
	else
		for k, v in pairs(metadata) do
			data[#data + 1] = {
				metadata = k,
				value = v,
			}
		end
	end

	if client.uiLoaded then
		return sendDisplayMetadata(data)
	end

	CreateThread(function()
		repeat Wait(100) until client.uiLoaded

		sendDisplayMetadata(data)
	end)
end

exports('displayMetadata', displayMetadata)

local function getItem(_, name)
	if not name then return Items end

	if type(name) ~= 'string' then return end

	name = name:lower()

	if name:sub(0, 7) == 'weapon_' then
		name = name:upper()
	end

	return Items[name]
end

setmetatable(Items --[[@as table]], {
	__call = getItem
})


local function Item(name, cb)
	local item = Items[name]
	if item then
		if not item.client?.export and not item.client?.event then
			item.effect = cb
		end
	end
end

local ox_inventory = exports[shared.resource]

Item('bandage', function(data, slot)
	local maxHealth = GetEntityMaxHealth(cache.ped)
	local health = GetEntityHealth(cache.ped)
	ox_inventory:useItem(data, function(data)
		if data then
			SetEntityHealth(cache.ped, math.min(maxHealth, math.floor(health + maxHealth / 16)))
			lib.notify({ description = 'You feel better already' })
		end
	end)
end)

Item('armour', function(data, slot)
	if GetPedArmour(cache.ped) < 100 then
		ox_inventory:useItem(data, function(data)
			if data then
				SetPlayerMaxArmour(PlayerData.id, 100)
				SetPedArmour(cache.ped, 100)
			end
		end)
	end
end)

client.parachute = false
Item('parachute', function(data, slot)
	if not client.parachute then
		ox_inventory:useItem(data, function(data)
			if data then
				local chute = `GADGET_PARACHUTE`
				SetPlayerParachuteTintIndex(PlayerData.id, -1)
				GiveWeaponToPed(cache.ped, chute, 0, true, false)
				SetPedGadget(cache.ped, chute, true)
				lib.requestModel(1269906701)
				client.parachute = { CreateParachuteBagObject(cache.ped, true, true), slot?.metadata?.type or -1 }
				if slot.metadata.type then
					SetPlayerParachuteTintIndex(PlayerData.id, slot.metadata.type)
				end
			end
		end)
	end
end)

Item('phone', function(data, slot)
	local success, result = pcall(function()
		return exports.npwd:isPhoneVisible()
	end)

	if success then
		exports.npwd:setPhoneVisible(not result)
	end
end)

local clothingItems = {
	'mask', 'hat', 'glasses', 'ears', 'necklace', 'watch', 'bracelet',
	'torso', 'arms', 'undershirt', 'legs', 'shoes', 'bag', 'armor', 'decals',
	'helmet', 'tshirt', 'bproof', 'pants', 'bags', 'chain', 'watches', 'bracelets',
}

local pulseClothingItems = {
	helmet = true,
	tshirt = true,
	bproof = true,
	pants = true,
	shoes = true,
	bags = true,
	arms = true,
	mask = true,
	glasses = true,
	ears = true,
	chain = true,
	watches = true,
	bracelets = true,
	decals = true,
	outfit = true,
}

local pulseClothingSlots = {
	helmet = 501,
	tshirt = 502,
	bproof = 503,
	pants = 504,
	shoes = 505,
	bags = 506,
	arms = 507,
	mask = 508,
	glasses = 509,
	ears = 510,
	chain = 511,
	watches = 512,
	bracelets = 513,
	decals = 514,
	outfit = 515,
}

local pulseNuiSlots = {
	helmet = 'hat',
	tshirt = 'torso',
	bproof = 'armor',
	pants = 'legs',
	bags = 'bag',
	chain = 'necklace',
	watches = 'watch',
	bracelets = 'bracelet',
}

local function canUsePulseClothing()
	return GetResourceState('pulse') == 'started'
end

local function notifyPulseClothingEquipped(name, label)
	local nuiSlot = pulseNuiSlots[name] or name

	if name == 'outfit' then
		SendNUIMessage({
			action = 'outfitEquipped',
			data = {
				equippedSlots = {},
				outfit = { name = name, label = label },
				lockedSlots = {},
			}
		})

		return
	end

	SendNUIMessage({
		action = 'outfitEquipped',
		data = {
			equippedSlots = {
				[nuiSlot] = { name = name, label = label },
			},
			outfit = false,
			lockedSlots = {},
		}
	})
end

local function equipPulseClothingItem(data, slot)
	local targetSlot = pulseClothingSlots[slot.name]
	if not targetSlot then return end

	ox_inventory:useItem(data, function(itemData)
		if not itemData then return end

		CreateThread(function()
			local moved = true

			if slot.slot ~= targetSlot then
				moved = lib.callback.await('ox_inventory:swapItems', false, {
					fromSlot = slot.slot,
					toSlot = targetSlot,
					fromType = 'player',
					toType = 'player',
					count = slot.count or 1,
				})
			end

			if moved ~= false then
				exports['pulse']:applyInventoryClothing(slot.name, slot.metadata)
				notifyPulseClothingEquipped(slot.name, itemData.label or slot.label or slot.name)
			end
		end)
	end)
end

-- clothing is no longer usable as an inventory item; only the pulse-resource
-- clothing item slots (unrelated to CubX) still equip through this handler.
local function clothingHandler(data, slot)
	if type(slot) ~= 'table' or type(slot.name) ~= 'string' then return end

	if canUsePulseClothing() and pulseClothingItems[slot.name] then
		equipPulseClothingItem(data, slot)
	end
end

for _, name in ipairs(clothingItems) do
	Item(name, clothingHandler)
end

Item('outfit', function(data, slot)
	if type(slot) ~= 'table' or not slot.metadata then return end

	if canUsePulseClothing() and slot.metadata.outfit then
		equipPulseClothingItem(data, slot)
	end
end)

exports('Items', function(item) return getItem(nil, item) end)
exports('ItemList', function(item) return getItem(nil, item) end)

return Items
