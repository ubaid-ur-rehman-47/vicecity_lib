if Cfg.Framework ~= 'esx' then return end

ESX = nil
JobData = {}
LastJobData = {}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                            INITIALIZE                            │
-- └──────────────────────────────────────────────────────────────────┘

-- Check if the framework is loaded
function HasFrameworkLoaded()
    return ESX ~= nil
end

-- Initialize the framework object
local function initateFramework()
    local function normalizeDuty(duty)
        return duty == nil or duty == true or duty == 1 or duty == 'on'
    end

    local function cacheJobData(data)
        if not data then return end

        local onDuty = normalizeDuty(data.onDuty)

        local newJob = {
            name = data.name,
            label = data.label,
            grade = data.grade,
            on_duty = onDuty
        }

        JobData.name = data.name
        JobData.label = data.label
        JobData.grade = data.grade
        JobData.grade_label = data.grade_label
        JobData.on_duty = onDuty

        return newJob
    end

    while ESX == nil do
        pcall(function()
            ESX = exports['es_extended']:getSharedObject()
        end)

        if not ESX then
            TriggerEvent('esx:getSharedObject', function(obj)
                ESX = obj
            end)
        end

        if not ESX then
            Wait(10)
        end
    end

    local function refreshPlayerData()
        local player = ESX.PlayerData
        if player and player.job then
            LastJobData = cacheJobData(player.job)
        end
    end

    refreshPlayerData()

    RegisterNetEvent('esx:playerLoaded', function(player)
        if player and player.job then
            LastJobData = cacheJobData(player.job)
        else
            refreshPlayerData()
        end

        TriggerEvent('cd_bridge:TriggerStartEvents', GetCurrentResourceName())
    end)

    RegisterNetEvent('esx:setJob', function(job)
        local old = LastJobData or { name=nil, label=nil, grade=0, on_duty=true }

        local new = {
            name = job.name,
            label = job.label,
            grade = job.grade,
            on_duty = normalizeDuty(job.onDuty)
        }

        if CurrentResourceName == 'cd_bridge' then
            TriggerEvent('cd_bridge:OnJobChanged', {
                job_changed = old.name ~= new.name,
                grade_changed = old.grade ~= new.grade,
                duty_changed = old.on_duty ~= new.on_duty,
                old = old,
                new = new
            })
        end

        LastJobData = new
        cacheJobData(job)
    end)
end

initateFramework()

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                              PLAYER                              │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the player object
function GetPlayer()
    return ESX.PlayerData
end

-- Check if the player has loaded (after character selection).
function HasPlayerLoadedIn()
    return ESX.PlayerLoaded or false
end

-- Get the player's identifier
function GetIdentifier()
    local Player = GetPlayer()
    if not Player then return end

    return Player.identifier
end

-- Get if the player is dead or dying
function GetIsPlayerDeadFromFramework()
    local Player = GetPlayer()
    if not Player then return end
    return LocalPlayer.state.isDead or Player.dead
end

-- Get if the player is cuffed_or_dead
function GetIsPlayerCuffedFromFramework()
    return nil
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                JOB                               │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the job name of the player
function GetJobName()
    return JobData.name
end

-- Get the job label of the player
function GetJobLabel()
    return JobData.label
end

-- Get the job grade of the player
function GetJobGrade()
    return JobData.grade
end

-- Get the job grade label of the player
function GetJobGradeLabel()
    return JobData.grade_label
end

-- Get if the player is on duty
function GetJobDuty()
    if Cfg.DisableDuty then
        return true
    end

    local customDuty = GetCustomJobDuty()
    if customDuty ~= nil then
        return customDuty
    end

    return JobData.on_duty
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                GANG                              │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the gang name of the player
function GetGangName()
    local customGang = GetCustomGang()
    if customGang ~= nil then
        return customGang.name
    end
    return 'none'
end

-- Get the gang label of the player
function GetGangLabel()
    local customGang = GetCustomGang()
    if customGang ~= nil then
        return customGang.label
    end
    return 'No Gang'
end

-- Get the gang grade of the player
function GetGangGrade()
    local customGang = GetCustomGang()
    if customGang ~= nil then
        return customGang.grade
    end
    return 0
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                               MONEY                              │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the amount of money a player has
function GetPlayerMoney(money_type)
    local Player = GetPlayer()
    if not Player then return end

    money_type = (money_type == 'cash') and 'money' or money_type

    for _, account in pairs(Player.accounts) do
        if account.name == money_type then
            return account.money
        end
    end
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                              VEHICLE                             │
-- └──────────────────────────────────────────────────────────────────┘

function FrameworkCreateVehicle(model, coords)
    local p = promise.new()
    local heading = coords.w or coords.h or 0.0

    ESX.Game.SpawnVehicle(model, vector3(coords.x, coords.y, coords.z), heading, function(veh)
        p:resolve(veh)
    end)

    return Citizen.Await(p)
end