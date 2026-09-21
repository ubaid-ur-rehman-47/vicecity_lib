--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(cache.serverId), function(_, _, value)
    if not value then client.onLogout() end
end)

RegisterNetEvent('qbx_core:client:onGroupUpdate', function(groupName, groupGrade)
    local groups = PlayerData.groups
    if not groupGrade then
        groups[groupName] = nil
    else
        groups[groupName] = groupGrade
    end
    client.setPlayerData('groups', groups)
end)

RegisterNetEvent('qbx_core:client:setGroups', function(groups)
    client.setPlayerData('groups', groups)
end)

function client.getPlayerStatus()
	local playerState = LocalPlayer.state
	return {
		hunger = playerState.hunger or 100,
		thirst = playerState.thirst or 100,
	}
end

function client.setPlayerStatus(values)
    local playerState = LocalPlayer.state
    for name, value in pairs(values) do
        if value > 100 or value < -100 then
            value = value * 0.0001
        end

        playerState:set(name, playerState[name] + value, true)
    end
end