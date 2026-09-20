RegisterNetEvent('cd_bridge:ConsolePrint', function(message)
    if type(message) == 'string' then
        Citizen.Trace(message)
    end
end)

RegisterNetEvent('cd_bridge:CompareCharacterInfo', function(serverCharInfo, debugOutput)
    local clientCharInfo = {
        charName = GetCharacterName(),
        jobName = GetJobName(),
        jobLabel = GetJobLabel(),
        jobGrade = GetJobGrade(),
        jobGradeLabel = GetJobGradeLabel(),
        onDuty = GetJobDuty(),
        gangName = GetGangName(),
        gangLabel = GetGangLabel(),
        gangGrade = GetGangGrade()
    }

    if type(debugOutput) == 'string' then
        for k, serverVal in pairs(serverCharInfo or {}) do
            local clientVal = clientCharInfo[k]
            if clientVal ~= nil then
                debugOutput = debugOutput:gsub(tostring(serverVal):gsub('([^%w])', '%%%1'), tostring(clientVal))
            end
        end

        Citizen.Trace(debugOutput)
    end

    local mismatchFound = {}

    for k, serverVal in pairs(serverCharInfo or {}) do
        local clientVal = clientCharInfo[k]

        if serverVal ~= clientVal then
            mismatchFound[#mismatchFound + 1] = {
                info = k,
                server = serverVal,
                client = clientVal
            }
        end
    end

    if #mismatchFound > 0 then
        local message = ''

        for _, m in pairs(mismatchFound) do
            message = message..string.format('^1%s: server = [%s] | client = [%s]\n', m.info, tostring(m.server), tostring(m.client))
        end

        message = message:sub(1, -2)
        ERROR('7903', 'Character info mismatch found between server and client.\n\n'..message)
        TriggerServerEvent('cd_bridge:CompareCharacterInfo', message)
    end
end)