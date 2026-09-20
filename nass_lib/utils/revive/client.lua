--No longer needed, kept for future scripts
function nass.revivePlayer(force)
    if not force and not nass.isPlayerDead(GetPlayerServerId(PlayerId())) then return end

    if GetResourceState('wasabi_ambulance') == 'started' then
        TriggerEvent("wasabi_ambulance:revive", true)
    elseif GetResourceState('ak47_ambulancejob') == 'started' then
        TriggerEvent('ak47_ambulancejob:skellyfix')
        TriggerEvent('ak47_ambulancejob:revive')
    elseif GetResourceState('ak47_qb_ambulancejob') == 'started' then
        TriggerEvent('ak47_qb_ambulancejob:skellyfix')
        TriggerEvent('ak47_qb_ambulancejob:revive')
    elseif GetResourceState('brutal_ambulancejob') == 'started' then
        TriggerEvent('brutal_ambulancejob:revive')
    elseif GetResourceState('osp_ambulance') == 'started' then
        TriggerEvent("hospital:client:Revive")
    elseif GetResourceState('esx_ambulancejob') == 'started' then
        TriggerEvent("esx_ambulancejob:revive", true)
    elseif GetResourceState('qb-ambulancejob') == 'started' then
        TriggerEvent("hospital:client:Revive")
    else
        --Add custom code here
    end
end

--No longer needed, kept for future scripts
function nass.isPlayerDead(playerID)
    if GetResourceState('wasabi_ambulance') == 'started' then
        return exports.wasabi_ambulance:isPlayerDead(playerID)
    elseif GetResourceState('ak47_ambulancejob') == 'started' then
        return exports['ak47_ambulancejob']:IsPlayerDown() or exports['ak47_ambulancejob']:IsPlayerDead()
    elseif GetResourceState('ak47_qb_ambulancejob') == 'started' then
        return exports['ak47_qb_ambulancejob']:IsPlayerDown() or exports['ak47_qb_ambulancejob']:IsPlayerDead()
    elseif GetResourceState('brutal_ambulancejob') == 'started' then
        return exports.brutal_ambulancejob:IsDead()
    elseif GetResourceState('osp_ambulance') == 'started' then
        local ambulanceData = exports.osp_ambulance:GetAmbulanceData(playerID)
        return ambulanceData.isDead or ambulanceData.inLastStand
    elseif GetResourceState('esx_ambulancejob') == 'started' then
        return Player(playerID).state.isDead
    elseif GetResourceState('qb-ambulancejob') == 'started' then
        return true
    else
        return true
    end
end