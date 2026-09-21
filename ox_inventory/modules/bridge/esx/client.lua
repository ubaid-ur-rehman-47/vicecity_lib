--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local ESX = setmetatable({}, {
	__index = function(self, index)
		local obj = exports.es_extended:getSharedObject()
		self.SetPlayerData = obj.SetPlayerData
		self.PlayerLoaded = obj.PlayerLoaded
		return self[index]
	end
})

function client.setPlayerData(key, value)
	PlayerData[key] = value
	ESX.SetPlayerData(key, value)
end

function client.getPlayerStatus()
	local status = { hunger = 0, thirst = 0 }

	TriggerEvent('esx_status:getStatus', 'hunger', function(s)
		status.hunger = s.getPercent()
	end)

	TriggerEvent('esx_status:getStatus', 'thirst', function(s)
		status.thirst = s.getPercent()
	end)

	return status
end

function client.setPlayerStatus(values)
	for name, value in pairs(values) do
		if value > 0 then TriggerEvent('esx_status:add', name, value) else TriggerEvent('esx_status:remove', name, -value) end
	end
end

RegisterNetEvent('esx:onPlayerLogout', client.onLogout)

AddEventHandler('esx:setPlayerData', function(key, value)
	if not PlayerData.loaded or GetInvokingResource() ~= 'es_extended' then return end

	if key == 'job' then
		key = 'groups'
		value = { [value.name] = value.grade }
	end

	PlayerData[key] = value
	OnPlayerData(key, value)
end)

local Weapon = require 'modules.weapon.client'

RegisterNetEvent('esx_policejob:handcuff', function()
	PlayerData.cuffed = not PlayerData.cuffed
	LocalPlayer.state:set('invBusy', PlayerData.cuffed, true)

	if not PlayerData.cuffed then return end

	Weapon.Disarm()
end)

RegisterNetEvent('esx_policejob:unrestrain', function()
	PlayerData.cuffed = false
	LocalPlayer.state:set('invBusy', PlayerData.cuffed, true)
end)