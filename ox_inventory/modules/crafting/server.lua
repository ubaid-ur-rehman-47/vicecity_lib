--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not lib then return end

local CraftingBenches = {}
local Items = require 'modules.items.server'
local Inventory = require 'modules.inventory.server'

local function createCraftingBench(id, data)
	CraftingBenches[id] = {}
	local recipes = data.items

	if recipes then
		for i = 1, #recipes do
			local recipe = recipes[i]
			local item = Items(recipe.name)

			if item then
				recipe.weight = item.weight
				recipe.slot = i
			else
				warn(('failed to setup crafting recipe (bench: %s, slot: %s) - item "%s" does not exist'):format(id, i, recipe.name))
			end

			for ingredient, needs in pairs(recipe.ingredients) do
				if needs < 1 then
					item = Items(ingredient)

					if item and not item.durability then
						item.durability = true
					end
				end
			end
		end

		CraftingBenches[id] = data
	end
end

for id, data in pairs(lib.load('data.crafting') or {}) do createCraftingBench(data.name or id, data) end

local function getCraftingCoords(source, bench, index)
	if not bench.points then
		return GetEntityCoords(GetPlayerPed(source))
	end

	local point = bench.points[index]
	if not point then return GetEntityCoords(GetPlayerPed(source)) end

	local rawCoords = point.coords or point
	return vec3(rawCoords.x, rawCoords.y, rawCoords.z)
end

local function isPlayerAuthorizedToCraft(source, bench)
	if not bench.AuthorisedType then
		return true
	end

	local xPlayer = server.GetPlayerFromId(source)
	if not xPlayer then
		return false
	end

	if bench.AuthorisedType == "WeaponSelling" then
		local identifier = (xPlayer.getIdentifier and xPlayer.getIdentifier()) or xPlayer.identifier

		if not identifier then
			for i = 0, GetNumPlayerIdentifiers(source) - 1 do
				local id = GetPlayerIdentifier(source, i)
				if id then
					identifier = id
					break
				end
			end
		end

		if not identifier then
			return false
		end

		local authorized = MySQL.query.await(
			[[SELECT w.crew_id
			FROM weaponselling_crew w
			INNER JOIN crew_membres m ON m.id_crew = w.crew_id
			WHERE m.identifier = ?
			LIMIT 1]],
			{ identifier }
		)

		if authorized and authorized[1] then
			return true
		end

		local shortId = identifier
		local colon = string.find(identifier, ":", 1, true)
		if colon then
			shortId = string.sub(identifier, colon + 1)
		end

		if shortId ~= identifier then
			local fallback = MySQL.query.await(
				[[SELECT w.crew_id
				FROM weaponselling_crew w
				INNER JOIN crew_membres m ON m.id_crew = w.crew_id
				WHERE m.identifier = ?
				LIMIT 1]],
				{ shortId }
			)
			if fallback and fallback[1] then
				return true
			end
		end

		return false
	end

	return false
end

lib.callback.register('ox_inventory:openCraftingBench', function(source, id, index)
	local left, bench = Inventory(source), CraftingBenches[id]

	if not left then return end

	if bench then
		local groups = bench.groups
		local coords = getCraftingCoords(source, bench, index)

		if not coords then return end

		if groups and not server.hasGroup(left, groups) then return end
		if #(GetEntityCoords(GetPlayerPed(source)) - coords) > 10 then return end
		if not isPlayerAuthorizedToCraft(source, bench) then return nil, nil, 'no_access' end

		if left.open and left.open ~= source then
			local inv = Inventory(left.open) --[[@as OxInventory]]

			if inv?.player then
				inv:closeInventory()
			end
		end

		left:openInventory(left)
	end

	return { label = left.label, type = left.type, slots = left.slots, weight = left.weight, maxWeight = left.maxWeight }
end)

local TriggerEventHooks = require 'modules.hooks.server'

lib.callback.register('ox_inventory:craftItem', function(source, id, index, recipeId, toSlot)
	local left, bench = Inventory(source), CraftingBenches[id]

	if not left then return end

	if bench then
		local groups = bench.groups
		local coords = getCraftingCoords(source, bench, index)

		if groups and not server.hasGroup(left, groups) then return end
		if #(GetEntityCoords(GetPlayerPed(source)) - coords) > 10 then return end
		if not isPlayerAuthorizedToCraft(source, bench) then return end

		local recipe = bench.items[recipeId]

		if recipe then
			local tbl, num = {}, 0

			for name in pairs(recipe.ingredients) do
				num += 1
				tbl[num] = name
			end

			local craftedItem = Items(recipe.name)
			local craftCount = (type(recipe.count) == 'number' and recipe.count) or (table.type(recipe.count) == 'array' and math.random(recipe.count[1], recipe.count[2])) or 1

			local newWeight = left.weight
			local items = Inventory.Search(left, 'slots', tbl) or {}
			for name, needs in pairs(recipe.ingredients) do
				if needs > 0 then
					local item = Items(name)
					if item then
						newWeight -= (item.weight * needs)
					end
				end
			end

			newWeight += (craftedItem.weight + (recipe.metadata?.weight or 0)) * craftCount

			if newWeight > left.maxWeight then return false, 'cannot_carry' end

			local items = Inventory.Search(left, 'slots', tbl) or {}
			table.wipe(tbl)

			for name, needs in pairs(recipe.ingredients) do
				if needs == 0 then break end

				local slots = items[name] or items

                if #slots == 0 then return end

				for i = 1, #slots do
					local slot = slots[i]

					if needs == 0 then
						if not slot.metadata.durability or slot.metadata.durability > 0 then
							break
						end
					elseif needs < 1 then
						local item = Items(name)
						local durability = slot.metadata.durability

						if durability and durability >= needs * 100 then
							if durability > 100 then
								local degrade = (slot.metadata.degrade or item.degrade) * 60
								local percentage = ((durability - os.time()) * 100) / degrade

								if percentage >= needs * 100 then
									tbl[slot.slot] = needs
									break
								end
							else
								tbl[slot.slot] = needs
								break
							end
						end
					elseif needs <= slot.count then
						tbl[slot.slot] = needs
						break
					else
						tbl[slot.slot] = slot.count
						needs -= slot.count
					end

					if needs == 0 then break end
					if needs > 0 and i == #slots then return end
				end
			end

			if not TriggerEventHooks('craftItem', {
				source = source,
				benchId = id,
				benchIndex = index,
				recipe = recipe,
				toInventory = left.id,
				toSlot = toSlot,
			}) then return false end

			local success = lib.callback.await('ox_inventory:startCrafting', source, id, recipeId)

			if success then
				for name, needs in pairs(recipe.ingredients) do
					if Inventory.GetItemCount(left, name) < needs then return end
				end

				for slot, count in pairs(tbl) do
					local invSlot = left.items[slot]

					if not invSlot then return end

					if count < 1 then
						local item = Items(invSlot.name)
						local durability = invSlot.metadata.durability or 100

						if durability > 100 then
							local degrade = (invSlot.metadata.degrade or item.degrade) * 60
							durability -= degrade * count
						else
							durability -= count * 100
						end

						if invSlot.count > 1 then
							local emptySlot = Inventory.GetEmptySlot(left)

							if emptySlot then
								local newItem = Inventory.SetSlot(left, item, 1, table.deepclone(invSlot.metadata), emptySlot)

								if newItem then
                                    Items.UpdateDurability(left, newItem, item, durability < 0 and 0 or durability)
								end
							end

							invSlot.count -= 1
                            invSlot.weight = Inventory.SlotWeight(item, invSlot)

							left:syncSlotsWithClients({
								{
									item = invSlot,
									inventory = left.id
								}
							}, true)
						else
                            Items.UpdateDurability(left, invSlot, item, durability < 0 and 0 or durability)
						end
					else
						local removed = invSlot and Inventory.RemoveItem(left, invSlot.name, count, nil, slot)
						if not removed then return end
					end
				end

				Inventory.AddItem(left, craftedItem, craftCount, recipe.metadata or {}, craftedItem.stack and toSlot or nil)
			end

			return success
		end
	end
end)