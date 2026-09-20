--- @param source number The players source.
--- @return table | nil # Returns a table containing the player's gang information, or nil if the integration is not available. 
function GetCustomGang(source)
    if Cfg.Gang == 'none' then return nil end

    if Cfg.Gang == 'rcore_gangs' then
        local ok, gang = pcall(function()
            return exports.rcore_gangs:GetPlayerGang(source)
        end)
        if not ok or type(gang) ~= 'table' then
            return nil
        end

        local rcoreConfigFile = LoadResourceFile('rcore_gangs', 'config.lua')
        if not rcoreConfigFile then
            error('[cd_bridge] Failed to load file: rcore_gangs/config.lua', 0)
            return nil
        end
        local env = {
            Config = {}
        }
        setmetatable(env, {__index = _G})

        local chunk, err = load(rcoreConfigFile, '@rcore_gangs/config.lua', 't', env)
        if not chunk then
            error('[cd_bridge] Failed to compile rcore_gangs/config.lua: '..tostring(err), 0)
            return nil
        end
        local success, execErr = pcall(chunk)
        if not success then
            error('[cd_bridge] Failed to execute rcore_gangs/config.lua: '..tostring(execErr), 0)
            return nil
        end

        local gangLabel = gang.tag
        local gangGrade = 0

        local RanksGroups = env.Config.RanksGroups
        if RanksGroups and type(RanksGroups) == 'table' then
            for _, ranksGroups in pairs(RanksGroups) do
                if ranksGroups.name == gang.name then
                    gangLabel = ranksGroups.label
                    for index, v in ipairs(ranksGroups.ranks) do
                        if v.label == gang.rank then
                            gangGrade = index-1
                            break
                        end
                    end
                end
            end
        else
            ERROR('3498', 'Invalid rcore_gangs/config.lua: Config.RanksGroups is not a table')
            return nil
        end

        return {
            name = gang.name,
            label = gangLabel,
            grade = gangGrade
        }

    elseif Cfg.Gang == 'av_gangs' then
        local ok, gang = pcall(function()
            return exports.av_gangs:getGang(source)
        end)

        if not ok or type(gang) ~= 'table' then
            return nil
        end

        return {
            name = gang.name,
            label = gang.label,
            grade = tonumber(gang.level)
        }

    elseif Cfg.Gang == 'other' then
        -- Add custom gang integration here
    end
end

--- @return table | nil # Returns a table containing all gangs on the server.
function GetCustomSharedGangs()
    if Cfg.Gang == 'none' then return end

    local normalisedGangs = {}

    if Cfg.Gang == 'rcore_gangs' then
        local gangs = DB.fetch('SELECT name, tag FROM gangs')
        if type(gangs) ~= 'table' then
            return
        end

        local rcoreConfigFile = LoadResourceFile('rcore_gangs', 'config.lua')
        if not rcoreConfigFile then
            error('[cd_bridge] Failed to load file: rcore_gangs/config.lua', 0)
            return nil
        end
        local env = {
            Config = {}
        }
        setmetatable(env, {__index = _G})

        local chunk, err = load(rcoreConfigFile, '@rcore_gangs/config.lua', 't', env)
        if not chunk then
            error('[cd_bridge] Failed to compile rcore_gangs/config.lua: '..tostring(err), 0)
            return nil
        end
        local success, execErr = pcall(chunk)
        if not success then
            error('[cd_bridge] Failed to execute rcore_gangs/config.lua: '..tostring(execErr), 0)
            return nil
        end

        local RanksGroups = env.Config.RanksGroups
        if not RanksGroups or type(RanksGroups) ~= 'table' then
            ERROR('3498', 'Invalid rcore_gangs/config.lua: Config.RanksGroups is not a table')
            return nil
        end

        for _, gang in ipairs(gangs) do
            local gangGrades = {}
            local gangLabel = gang.tag
            local bossGrade = nil

            for _, ranksGroup in pairs(RanksGroups) do
                for index, rank in ipairs(ranksGroup.ranks) do
                    gangLabel = ranksGroup.label

                    gangGrades[index - 1] = {
                        grade = index - 1,
                        name = rank.label
                    }

                    if rank.leader then
                        bossGrade = index - 1
                    end
                end
            end

            normalisedGangs[gang.name] = {
                name = gang.name,
                label = gangLabel,
                grades = gangGrades,
                boss_grade = bossGrade,
            }
        end

        return normalisedGangs

    elseif Cfg.Gang == 'av_gangs' then
        local ok, gangs = pcall(function()
            return exports.av_gangs:getGangList()
        end)

        if not ok or type(gangs) ~= 'table' then
            return
        end

        for index, gang  in ipairs(gangs) do
            normalisedGangs[gang .name] = {
                name = gang .name,
                label = gang .label,
                grades = {
                    [0] = {
                        grade = 0,
                        name = 'Member'
                    }
                },
                boss_grade = 0
            }
        end

        return normalisedGangs

    elseif Cfg.Gang == 'other' then
        -- Add custom gang integration here
    end
end