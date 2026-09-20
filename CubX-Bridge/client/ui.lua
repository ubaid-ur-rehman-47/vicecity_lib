--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local isTextUIActive = false

function ShowTextUI(text, options)
    if not text then return end
    
    options = options or {}
    local position = options.position or (Config.Notifications and Config.Notifications.textUIPosition) or "right-center"
    
    if CBUX.HasOxLib then
        lib.showTextUI(text, {
            position = position,
            icon = options.icon,
            iconColor = options.iconColor,
            style = options.style
        })
        isTextUIActive = true
        return
    end
    
    if CBUX.Framework == "qbcore" or CBUX.Framework == "qbox" then
        if CBUX.FrameworkObject then
            exports["qb-core"]:DrawText(text, position)
            isTextUIActive = true
            return
        end
    end
    
    isTextUIActive = true
    CreateThread(function()
        while isTextUIActive do
            SetTextScale(0.35, 0.35)
            SetTextFont(4)
            SetTextCentre(false)
            SetTextColour(255, 255, 255, 255)
            SetTextOutline()
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(text)
            
            local x = 0.85
            local y = 0.5
            
            if position == "left-center" then
                x = 0.15
                y = 0.5
            elseif position == "top-center" then
                x = 0.5
                y = 0.1
                SetTextCentre(true)
            elseif position == "bottom-center" then
                x = 0.5
                y = 0.9
                SetTextCentre(true)
            end
            
            EndTextCommandDisplayText(x, y)
            Wait(0)
        end
    end)
end

function HideTextUI()
    isTextUIActive = false
    if CBUX.HasOxLib then
        lib.hideTextUI()
        return
    end
    
    if CBUX.Framework == "qbcore" or CBUX.Framework == "qbox" then
        exports["qb-core"]:HideText()
        return
    end
end

function IsTextUIActive()
    if CBUX.HasOxLib then
        return lib.isTextUIOpen()
    end
    return isTextUIActive
end

function Draw3DText(coords, text, scale, font)
    scale = scale or 0.35
    font = font or 4
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    
    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(font)
        SetTextProportional(true)
        SetTextColour(255, 255, 255, 255)
        SetTextOutline()
        SetTextCentre(true)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(x, y)
    end
end

function OpenMenu(id, options)
    if not id or not options then
        CBUX.Utils.Error("OpenMenu: id and options required")
        return
    end
    
    if CBUX.HasOxLib then
        lib.registerContext({
            id = id,
            title = options.title or "Menu",
            options = options.items or options
        })
        lib.showContext(id)
        return
    end
    
    if CBUX.Framework == "qbcore" or CBUX.Framework == "qbox" then
        local qbMenu = {}
        local items = options.items or options
        
        for i, item in ipairs(items) do
            local index = #qbMenu + 1
            qbMenu[index] = {
                header = item.title or item.header,
                txt = item.description or item.txt or "",
                icon = item.icon,
                params = {
                    event = item.event,
                    args = item.args
                }
            }
        end
        exports["qb-menu"]:openMenu(qbMenu)
        return
    end
    
    CBUX.Utils.Warn("OpenMenu: No compatible menu system found")
end

function CloseMenu()
    if CBUX.HasOxLib then
        lib.hideContext()
        return
    end
    
    if CBUX.Framework == "qbcore" or CBUX.Framework == "qbox" then
        exports["qb-menu"]:closeMenu()
        return
    end
end

function InputDialog(header, inputs)
    if not header or not inputs then
        CBUX.Utils.Error("InputDialog: header and inputs required")
        return nil
    end
    
    if CBUX.HasOxLib then
        return lib.inputDialog(header, inputs)
    end
    
    if CBUX.Framework == "qbcore" or CBUX.Framework == "qbox" then
        local qbInputs = {}
        for i, input in ipairs(inputs) do
            local index = #qbInputs + 1
            qbInputs[index] = {
                text = input.label or input.text,
                name = input.name or ("input_" .. index),
                type = input.type or "text",
                isRequired = input.required
            }
        end
        
        return exports["qb-input"]:ShowInput({
            header = header,
            submitText = "Submit",
            inputs = qbInputs
        })
    end
    
    CBUX.Utils.Warn("InputDialog: No compatible input system found")
    return nil
end

function AlertDialog(options)
    if not options then
        return "cancel"
    end
    
    if CBUX.HasOxLib then
        return lib.alertDialog({
            header = options.header or options.title or "Alert",
            content = options.content or options.message or "",
            centered = options.centered,
            cancel = options.cancel ~= false,
            size = options.size
        })
    end
    
    CBUX.Utils.Print("Alert:", options.header, "-", options.content)
    return "confirm"
end

function KeyboardInput(title, defaultText, maxLength)
    DisplayOnscreenKeyboard(1, title or "FMMC_KEY_TIP8", "", defaultText or "", "", "", "", maxLength or 30)
    
    while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        Wait(0)
    end
    
    if GetOnscreenKeyboardResult() then
        return GetOnscreenKeyboardResult()
    end
    
    return nil
end

function ShowRadialMenu(menuId)
    if not CBUX.HasOxLib then
        CBUX.Utils.Warn("ShowRadialMenu requires ox_lib")
        return
    end
    lib.showRadialMenu(menuId)
end

function HideRadialMenu()
    if CBUX.HasOxLib then
        lib.hideRadialMenu()
    end
end

exports("ShowTextUI", ShowTextUI)
exports("HideTextUI", HideTextUI)
exports("IsTextUIActive", IsTextUIActive)
exports("Draw3DText", Draw3DText)
exports("OpenMenu", OpenMenu)
exports("CloseMenu", CloseMenu)
exports("InputDialog", InputDialog)
exports("AlertDialog", AlertDialog)
exports("KeyboardInput", KeyboardInput)
exports("ShowRadialMenu", ShowRadialMenu)
exports("HideRadialMenu", HideRadialMenu)
exports("DrawText", ShowTextUI)
exports("HideText", HideTextUI)