--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local isProgressActive = false

function Progressbar(options)
    if not options or not options.duration then
        CBUX.Utils.Error("Progressbar: duration is required")
        return false
    end
    
    if isProgressActive then
        CBUX.Utils.Warn("Progressbar: Another progress is active")
        return false
    end
    
    isProgressActive = true
    local duration = options.duration
    local label = options.label or ""
    local useWhileDead = options.useWhileDead or false
    local canCancel = options.canCancel or false
    local onFinish = options.onFinish
    local onCancel = options.onCancel
    
    if not useWhileDead then
        if exports["CubX-Bridge"]:IsDead() then
            isProgressActive = false
            if onCancel then
                onCancel()
            end
            return false
        end
    end
    
    if CBUX.HasOxLib then
        if Config.Progressbar.useOxLib then
            local libOptions = {
                duration = duration,
                label = label,
                useWhileDead = useWhileDead,
                canCancel = canCancel,
                disable = options.disableControls or {},
                anim = options.anim,
                prop = options.prop
            }
            local success = lib.progressBar(libOptions)
            isProgressActive = false
            if success then
                if onFinish then
                    onFinish()
                end
            elseif onCancel then
                onCancel()
            end
            return success
        end
    end
    
    if CBUX.Framework == "qbcore" or CBUX.Framework == "qbox" then
        if CBUX.FrameworkObject and CBUX.FrameworkObject.Functions and CBUX.FrameworkObject.Functions.Progressbar then
            local disableControls = options.disableControls or {}
            local progressId = "cbux_progress_" .. math.random(1000, 9999)
            local disable = {
                disableMovement = disableControls.disableMovement or false,
                disableCarMovement = disableControls.disableCarMovement or false,
                disableMouse = disableControls.disableMouse or false,
                disableCombat = disableControls.disableCombat or false
            }
            
            CBUX.FrameworkObject.Functions.Progressbar(progressId, label, duration, useWhileDead, canCancel, disable, options.anim or {}, options.prop or {}, options.propTwo or {}, function()
                isProgressActive = false
                if onFinish then
                    onFinish()
                end
            end, function()
                isProgressActive = false
                if onCancel then
                    onCancel()
                end
            end)
            return true
        end
    end
    
    CreateThread(function()
        local startTime = GetGameTimer()
        local endTime = startTime + duration
        local canceled = false
        
        while GetGameTimer() < endTime do
            local progress = (GetGameTimer() - startTime) / duration
            DrawRect(0.5, 0.95, 0.3, 0.02, 50, 50, 50, 200)
            DrawRect(0.35 + (progress * 0.15), 0.95, progress * 0.3, 0.015, 0, 150, 255, 255)
            
            SetTextScale(0.35, 0.35)
            SetTextFont(4)
            SetTextCentre(true)
            SetTextColour(255, 255, 255, 255)
            SetTextOutline()
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(label .. " (" .. math.floor(progress * 100) .. "%)")
            EndTextCommandDisplayText(0.5, 0.92)
            
            if canCancel then
                if IsControlJustPressed(0, 200) then
                    canceled = true
                    break
                end
            end
            Wait(0)
        end
        
        isProgressActive = false
        if canceled then
            if onCancel then
                onCancel()
            end
        else
            if onFinish then
                onFinish()
            end
        end
    end)
    return true
end

function ProgressCircle(options)
    if not options or not options.duration then
        CBUX.Utils.Error("ProgressCircle: duration is required")
        return false
    end
    
    if CBUX.HasOxLib then
        local libOptions = {
            duration = options.duration,
            label = options.label,
            useWhileDead = options.useWhileDead or false,
            canCancel = options.canCancel or false,
            disable = options.disableControls or {},
            anim = options.anim,
            prop = options.prop
        }
        return lib.progressCircle(libOptions)
    end
    
    return Progressbar(options)
end

function IsProgressActive()
    if CBUX.HasOxLib then
        return lib.progressActive()
    end
    return isProgressActive
end

function CancelProgress()
    if CBUX.HasOxLib then
        lib.cancelProgress()
        return
    end
    isProgressActive = false
end

function SkillCheck(difficulty, inputs)
    if not CBUX.HasOxLib then
        CBUX.Utils.Warn("SkillCheck requires ox_lib")
        return true
    end
    return lib.skillCheck(difficulty, inputs)
end

exports("Progressbar", Progressbar)
exports("ProgressCircle", ProgressCircle)
exports("IsProgressActive", IsProgressActive)
exports("CancelProgress", CancelProgress)
exports("SkillCheck", SkillCheck)
exports("Progress", Progressbar)
exports("ShowProgress", Progressbar)