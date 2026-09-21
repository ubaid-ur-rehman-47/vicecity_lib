--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not lib.checkDependency('ox_core', '0.21.3', true) then return end

local Ox = require '@ox_core.lib.init' --[[@as OxClient]]
local player = Ox.GetPlayer()

RegisterNetEvent('ox:playerLogout', client.onLogout)

RegisterNetEvent('ox:setGroup', function(name, grade)
    PlayerData.groups[name] = grade
    OnPlayerData('groups')
end)

function client.getPlayerStatus()
	return {
		hunger = 100 - (player.getStatus('hunger') or 0),
		thirst = 100 - (player.getStatus('thirst') or 0),
	}
end

function client.setPlayerStatus(values)
    for name, value in pairs(values) do
        if value > 100 or value < -100 then
            if (name == 'hunger' or name == 'thirst') then
                value = -value
            end

            value = value * 0.0001
        end

        player.addStatus(name, value)
    end
end