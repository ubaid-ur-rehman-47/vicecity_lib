--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox
--[[

	Intended for use with https://github.com/project-error/pefcl
	config.useFrameworkIntegration.resource should be set as "ox_inventory"

	This isn't intended for use with frameworks with their own accounts,
	use the proper pefcl-framework resources and ensure item/account syncing
	works on your own.
]]

local Inventory = require 'modules.inventory.server'

exports('addCash', function(source, amount)
	Inventory.AddItem(source, 'money', amount)
end)

exports('removeCash', function(source, amount)
	Inventory.RemoveItem(source, 'money', amount)
end)

exports('getCash', function(source)
	return Inventory.GetItemCount(source, 'money')
end)

exports('getCards', function(source)
	local items = Inventory(source)?.items

	if items then
		local retval, num = {}, 0

		for _, data in pairs(items) do
			if data.name == 'mastercard' then
				num += 1
				retval[num] = {
					id = data.metadata.id,
					holder = data.metadata.holder,
					number = data.metadata.number
				}
			end
		end

		return retval
	end
end)

exports('giveCard', function(source, card)
	Inventory.AddItem(source, 'mastercard', 1, {
		id = card.id,
		holder = card.holder,
		number = card.number,
		description = ('Card Number: %s'):format(card.number)
	})
end)

exports('getBank', function() end)
