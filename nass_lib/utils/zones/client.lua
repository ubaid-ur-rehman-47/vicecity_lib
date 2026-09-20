function controlCamera(cam)
    local camPos = GetCamCoord(cam)
    local camRot = GetCamRot(cam, 2)
    local frameTime = GetFrameTime()
    local mouseX = GetDisabledControlNormal(0, 1)
    local mouseY = GetDisabledControlNormal(0, 2)
    local _, fwdVec, upVec, _ = GetCamMatrix(cam)
    local upDir = vector3(0.0, 0.0, 1.0)
    local rightDir = norm(vector3(fwdVec.y, -fwdVec.x, 0.0))
    local fwdDir = norm(vector3(fwdVec.x, fwdVec.y, 0.0))
    local speedMultiplier = 30.0
    if IsDisabledControlPressed(0, Config.zoneControls.speed.faster.control) then
        speedMultiplier = 60.0
    elseif IsDisabledControlPressed(0, Config.zoneControls.speed.slower.control) then
        speedMultiplier = 15.0
    end

    if IsDisabledControlPressed(0, Config.zoneControls.z.up.control) then
        camPos = camPos + (upDir * (speedMultiplier * frameTime))
    elseif IsDisabledControlPressed(0, Config.zoneControls.z.down.control) then
        camPos = camPos - (upDir * (speedMultiplier * frameTime))
    end

    if IsDisabledControlPressed(0, Config.zoneControls.x.fwd.control) then
        camPos = camPos + (fwdDir * (speedMultiplier * frameTime))
    elseif IsDisabledControlPressed(0, Config.zoneControls.x.back.control) then
        camPos = camPos - (fwdDir * (speedMultiplier * frameTime))
    end

    if IsDisabledControlPressed(0, Config.zoneControls.y.right.control) then
        camPos = camPos + (rightDir * (speedMultiplier * frameTime))
    elseif IsDisabledControlPressed(0, Config.zoneControls.y.left.control) then
        camPos = camPos - (rightDir * (speedMultiplier * frameTime))
    end

    if mouseY ~= 0 then
        local pitch = math.max(-80.0, math.min(80.0, camRot.x - (mouseY * 500.0 * frameTime)))
        camRot = vector3(pitch, camRot.y, camRot.z)
    end

    if mouseX ~= 0 then
        local yaw = camRot.z - (mouseX * 500.0 * frameTime)
        camRot = vector3(camRot.x, camRot.y, yaw)
    end

    SetCamCoord(cam, camPos.x, camPos.y, camPos.z)
    SetCamRot(cam, camRot.x, camRot.y, camRot.z, 2)
    return camPos, camRot
end

--Options
-- zoneData
-- heading
-- car
-- prop
function nass.pickLocation(options)
    local vehicle, object
    local setupZone
    if options.zoneData then
        setupZone = lib.zones.poly({
            points = options.zoneData,
            thickness = 50,
            debug = true,
        })
    end

    local ped = PlayerPedId()
    local fwdVec, rightVec, upVec, plyPos = GetEntityMatrix(ped)
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", plyPos.x, plyPos.y, plyPos.z, 0, 0, 0, 50)
    local dirHeading = 0.0
    local isInside = false
    local destPos = plyPos
    SetCamCoord(cam, plyPos.x, plyPos.y, plyPos.z+3.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)
    
    
    
    if options.car then
        nass.loadModel(options.car)
        vehicle = CreateVehicle(options.car, destPos.x, destPos.y, destPos.z, dirHeading, false, true)
        SetEntityCollision(vehicle, false, false)
        SetEntityAlpha(vehicle, 153)
    elseif options.prop then
        nass.loadModel(options.prop)
        object = CreateObject(options.prop, destPos.x, destPos.y, destPos.z, false, true, false)
        SetEntityCollision(object, false, false)
        SetEntityAlpha(object, 153)
    end
    
    local scaleform = nass.createInstructionalMessageScaleform({
        {Config.zoneControls.input.cancel.label, Config.zoneControls.input.cancel.control},
        {Config.zoneControls.input.select.label, Config.zoneControls.input.select.control},
        {Config.zoneControls.input.rotDown.label, Config.zoneControls.input.rotDown.control},
        {Config.zoneControls.speed.slower.label, Config.zoneControls.speed.slower.control},
        {Config.zoneControls.speed.faster.label, Config.zoneControls.speed.faster.control},
        {Config.zoneControls.z.down.label, Config.zoneControls.z.down.control},
        {Config.zoneControls.z.up.label, Config.zoneControls.z.up.control},
    })

    while true do
        Wait(0)
        if setupZone then
            if setupZone:contains(vec3(destPos.x, destPos.y, destPos.z)) then
                isInside = true
            else
                isInside = false
            end
        end
        DisableAllControlActions(0)
        controlCamera(cam)
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
        local rightVecNew, fwdVecNew, upVecNew, newPos = GetCamMatrix(cam)
        local rayTest = StartExpensiveSynchronousShapeTestLosProbe(newPos.x, newPos.y, newPos.z, newPos.x + (fwdVecNew.x * 100.0), newPos.y + (fwdVecNew.y * 100.0), newPos.z + (fwdVecNew.z * 100.0), 1, ped, 4)
        local hitResult, hit, hitPosition, hitSurfaceNormal, hitEntity = GetShapeTestResult(rayTest)
        
        destPos = hitPosition

        if (#(newPos - plyPos) > 300.0 and not options.ignoreDistance) or IsDisabledControlJustPressed(0, Config.zoneControls.input.cancel.control) then
            if options.car and vehicle then
                SetEntityAsMissionEntity(vehicle, true, true)
                DeleteVehicle(vehicle)
            elseif options.prop and object then
                DeleteObject(object)
            end
            SetCamActive(cam, false)
            RenderScriptCams(false, false, 0, true, false)
            DestroyCam(cam, false)

            if options.zoneData then setupZone:remove() end
            return
        end

        if IsDisabledControlJustPressed(0, Config.zoneControls.input.select.control) then
            if isInside or not options.zoneData then
                SetCamActive(cam, false)
                RenderScriptCams(false, false, 0, true, false)
                DestroyCam(cam, false)
                if options.zoneData then setupZone:remove() end
                if options.car and vehicle then
                    SetEntityAsMissionEntity(vehicle, true, true)
                    DeleteVehicle(vehicle)
                elseif options.prop and object then
                    DeleteObject(object)
                end
                return vector4(destPos.x, destPos.y, destPos.z, dirHeading)
            else
                nass.notify("You must be within the designated area.")
            end
        end

        if options.heading or options.car or options.prop then
            if IsDisabledControlPressed(0, Config.zoneControls.input.rotUp.control) then
                dirHeading = dirHeading + (500.0 * GetFrameTime())
            elseif IsDisabledControlPressed(0, Config.zoneControls.input.rotDown.control) then
                dirHeading = dirHeading - (500.0 * GetFrameTime())
            end

            if dirHeading < 0.0 then
                dirHeading = 359.9
            elseif dirHeading >= 360.0 then
                dirHeading = 0.0
            end
        end

        if options.car and vehicle then
            SetEntityCoords(vehicle, destPos.x, destPos.y, destPos.z)
            SetEntityHeading(vehicle, dirHeading)
        elseif options.prop and object then
            SetEntityCoords(object, destPos.x, destPos.y, destPos.z)
            SetEntityHeading(object, dirHeading)
        else
            DrawMarker(1, destPos.x, destPos.y, destPos.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, isInside and 0 or 255, isInside and 255 or 0, 0, 100, false, true, 2, nil, nil, false)
            if options.heading then
                DrawMarker(3, destPos.x, destPos.y, destPos.z + 1.0, 0, 0, 0, (-dirHeading - 90.0), 90.0, 90.0, 0.5, 0.5, 0.5, isInside and 0 or 255, isInside and 255 or 0, 0, 100, false, false, 2, nil, nil, false)
            end
        end
    end
    SetScaleformMovieAsNoLongerNeeded()
end

function nass.editZone(inputPoints)
    local points = inputPoints or {}
    local ped = PlayerPedId()
    local fwd, right, up, plyPos = GetEntityMatrix(ped)
    local cameraPos = plyPos + (up * 2)
    local cameraRotation = vector3(-35.0, 0.0, GetEntityHeading(ped))

    local createdZone
    local zCoord
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cameraPos.x, cameraPos.y, cameraPos.z, 0, 0, 0, 50)
    SetCamCoord(cam, cameraPos.x, cameraPos.y, cameraPos.z)
    SetCamRot(cam, cameraRotation.x, cameraRotation.y, cameraRotation.z, 2)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)

    local scaleform = nass.createInstructionalMessageScaleform({
        {'Done', Config.zoneControls.input.cancel.control},
        {'Undo', Config.zoneControls.input.undo.control},
        {'Select', Config.zoneControls.input.select.control},
        {'Slower', Config.zoneControls.speed.slower.control},
        {'Faster', Config.zoneControls.speed.faster.control},
        {'Down', Config.zoneControls.z.down.control},
        {'Up', Config.zoneControls.z.up.control},
        --[[{'Right', Config.zoneControls.y.right.control},
        {'Left', Config.zoneControls.y.left.control},
        {'Back', Config.zoneControls.x.back.control},
        {'Forward', Config.zoneControls.x.fwd.control},]]
    })

    while true do
        Wait(0)
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)

        if IsDisabledControlJustPressed(0, Config.zoneControls.input.cancel.control) then
            SetCamActive(cam, false)
            RenderScriptCams(false, false, 0, true, false)
            DestroyCam(cam, false)
            if createdZone then createdZone:remove() end
            return points
        end

        DisableAllControlActions(0)
        cameraPos, cameraRotation = controlCamera(cam)  

        right,fwd,up,pos = GetCamMatrix(cam)   
        local rayTest = StartExpensiveSynchronousShapeTestLosProbe(pos.x,pos.y,pos.z, pos.x+(fwd.x*100.0),pos.y+(fwd.y*100.0),pos.z+(fwd.z*100.0), 1, PlayerPedId(), 4)
        local retval, hit, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(rayTest)  


        if IsDisabledControlJustPressed(0, Config.zoneControls.input.select.control) then
            if not zCoord then zCoord = hitCoords.z end
            local newPoint = vector3(hitCoords.x, hitCoords.y, zCoord-5.0)
            table.insert(points, newPoint)
            if createdZone then createdZone:remove() end
            createdZone = lib.zones.poly({
                points = points,
                thickness = 50,
                debug = true,
            })
        end

        if IsDisabledControlJustPressed(0, Config.zoneControls.input.undo.control) and #points > 0 then
            table.remove(points, #points)
            if createdZone then
                if createdZone then createdZone:remove() end
                if #points > 0 then
                    createdZone = lib.zones.poly({
                        points = points,
                        thickness = 20,
                        debug = true,
                    })
                end
            end
        end
        
        DrawLine(hitCoords.x, hitCoords.y, hitCoords.z, hitCoords.x, hitCoords.y, hitCoords.z + 10, 255, 0, 0, 255)
    end
    SetScaleformMovieAsNoLongerNeeded()
end

function nass.createInstructionalMessageScaleform(keysTable)
    local scaleform = RequestScaleformMovie("instructional_buttons")
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(10)
    end
    BeginScaleformMovieMethod(scaleform, "CLEAR_ALL")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_CLEAR_SPACE")
    ScaleformMovieMethodAddParamInt(200)
    EndScaleformMovieMethod()

    for btnIndex, keyData in ipairs(keysTable) do
        local btn = GetControlInstructionalButton(0, keyData[2], true)

        BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(btnIndex - 1)
        ScaleformMovieMethodAddParamPlayerNameString(btn)
        BeginTextCommandScaleformString("STRING")
        AddTextComponentSubstringKeyboardDisplay(keyData[1])
        EndTextCommandScaleformString()
        EndScaleformMovieMethod()
    end

    BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND_COLOUR")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(80)
    EndScaleformMovieMethod()

    return scaleform
end