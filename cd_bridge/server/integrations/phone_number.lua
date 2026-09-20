-- Get a players phone number.
--- @param source number The player's server ID.
--- @return string|number|nil # The player's phone number, or nil if not found.
function GetPhoneNumber(source)
    local Player = GetPlayer(source)
    if not Player then return end

    local identifier = GetIdentifier(source)
    if not identifier then return end

    if Cfg.Phone == 'esx_phone' then
        local Result = DatabaseQuery('SELECT phone_number FROM users WHERE identifier=?', {identifier})
        if Result and Result[1] and Result[1].phone_number then
            return Result[1].phone_number
        end

    elseif Cfg.Phone == 'gcphone' then
        return exports.gcphone:getPhoneNumber(source)

    elseif Cfg.Phone == 'gksphone' then
        return exports.gksphone:GetPhoneBySource(source)

    elseif Cfg.Phone == 'high-phone' then
        return exports['high-phone']:getPlayerPhoneNumber(source)

    elseif Cfg.Phone == 'lb-phone' then
        return exports['lb-phone']:GetEquippedPhoneNumber(source)

    elseif Cfg.Phone == 'npwd' then
        local phoneData = exports.npwd:getPlayerData({ identifier = identifier })
        if phoneData and phoneData.phoneNumber then
            return phoneData.phoneNumber
        end

    elseif Cfg.Phone == 'ns_Phone' then
        return exports.ns_Phone:GetPhoneNumber(source)

    elseif Cfg.Phone == 'okokPhone' then
        return exports.okokPhone:getPhoneNumberFromSource(source)

    elseif Cfg.Phone == 'qb-phone' then
        return Player.PlayerData.charinfo.phone

    elseif Cfg.Phone == 'qbx_npwd' then
        local phoneData = exports.npwd:getPlayerData({ identifier = identifier })
        if phoneData and phoneData.phoneNumber then
            return phoneData.phoneNumber
        end

    elseif Cfg.Phone == 'qs-smartphone' then
        local function getNumber(export, fn)
            local ok, result = pcall(function()
                return exports[export][fn](source)
            end)

            if not ok or not result then return nil end

            if type(result) == 'table' then
                result = result.phoneNumber or result.phone_number or result.number or result.phone
            end

            result = tostring(result or '')
            return result ~= '' and result or nil
        end

    return getNumber('qs-smartphone', 'GetCurrentPhoneNumber') or getNumber('qs-base', 'GetPlayerPhone')

    elseif Cfg.Phone == 'qs-smartphone-pro' then
        return exports['qs-smartphone-pro']:GetPhoneNumberFromIdentifier(identifier, false)

    elseif Cfg.Phone == 'roadphone' then
        return exports.roadphone:getNumberFromIdentifier(identifier)

    elseif Cfg.Phone == 'sd-phone' then
        return exports['sd-phone']:getPhoneNumber(source)

    elseif Cfg.Phone == 'yseries' then
        return exports.yseries:GetPhoneNumberBySourceId(source)

    elseif Cfg.Phone == '17mov_Phone' then
        return exports['17mov_Phone']:GetNumberFromPlayer(source)

    elseif Cfg.Phone == 'other' then
        -- Implement custom logic for other phone systems here.
        -- Return the player's phone number, or nil if not found.
    end
end

-- Check if a phone number already exists in the database.
--- @param source number The players source.
--- @param phoneNumber string The phone number to check.
--- @return boolean # True if the phone number exists, false otherwise.
function DoesPhoneNumberAlreadyExist(source, phoneNumber)
    local identifier = GetIdentifier(source)
    if not identifier then return false end

    if Cfg.Phone == 'esx_phone' then
        local Result = DB.fetch('SELECT 1 FROM users WHERE phone_number=?', {phoneNumber})
        return (Result and Result[1]) ~= nil

    elseif Cfg.Phone == 'gcphone' then
        local Result = DB.fetch('SELECT 1 FROM gcphone_users WHERE phone_number=?', {phoneNumber})
        return (Result and Result[1]) ~= nil

    elseif Cfg.Phone == 'gksphone' then
        local data = exports.gksphone:GetPhoneDataByNumber(phoneNumber)
        return data ~= nil and data ~= false

    elseif Cfg.Phone == 'high-phone' then
        local data = exports['high-phone']:getPlayerByPhone(phoneNumber)
        return data ~= nil and data ~= false

    elseif Cfg.Phone == 'lb-phone' then
        local Result = DB.fetch('SELECT 1 FROM phone_phones WHERE phone_number=?', {phoneNumber})
        return (Result and Result[1]) ~= nil

    elseif Cfg.Phone == 'npwd' then
        if Cfg.Framework == 'esx' then
            local Result = DB.fetch('SELECT 1 FROM users WHERE phone_number=?', {phoneNumber})
            return (Result and Result[1]) ~= nil

        elseif Cfg.Framework == 'qbcore' then
            local Result = DB.fetch('SELECT charinfo FROM players')
            if Result then
                for cd = 1, #Result do
                    if json.decode(Result[cd].charinfo).phone == phoneNumber then
                        return true
                    end
                end
            end
        end

    elseif Cfg.Phone == 'ns_Phone' then
        local data = exports.ns_Phone:GetIdentifierByPhoneNumber(phoneNumber)
        return data ~= nil and data ~= false

    elseif Cfg.Phone == 'okokPhone' then
        local Result = DB.fetch('SELECT 1 FROM okokphone_users WHERE phone_number=?', {phoneNumber})
        return (Result and Result[1]) ~= nil

    elseif Cfg.Phone == 'qb-phone' then
        local Result = DB.fetch('SELECT charinfo FROM players')
        if Result then
            for cd = 1, #Result do
                if json.decode(Result[cd].charinfo).phone == phoneNumber then
                    return true
                end
            end
        end

    elseif Cfg.Phone == 'qbx_npwd' then
        local Result = DB.fetch('SELECT phone_number FROM users WHERE phone_number=?', {phoneNumber})
        return (Result and Result[1]) ~= nil

    elseif Cfg.Phone == 'qs-smartphone' then
        local currentNumber = GetPhoneNumber(source)
        if currentNumber and tostring(currentNumber) == tostring(phoneNumber) then
            return true
        end

        local ok, Result = pcall(function()
            return DB.fetch([[
                SELECT 1 FROM qs_phone_metadata
                WHERE JSON_UNQUOTE(JSON_EXTRACT(data, '$.phoneNumber')) = ?
                   OR JSON_UNQUOTE(JSON_EXTRACT(data, '$.phone_number')) = ?
                   OR JSON_UNQUOTE(JSON_EXTRACT(data, '$.number')) = ?
                LIMIT 1
            ]], {phoneNumber, phoneNumber, phoneNumber})
        end)

        return ok and Result and Result[1] ~= nil

    elseif Cfg.Phone == 'qs-smartphone-pro' then
        local data = exports['qs-smartphone-pro']:GetPhoneNumberFromIdentifier(identifier, false)
        return data ~= nil and data ~= false

    elseif Cfg.Phone == 'roadphone' then
        local data = exports.roadphone:getNumberFromIdentifier(identifier)
        return data ~= nil and data ~= false

    elseif Cfg.Phone == 'sd-phone' then
        return exports['sd-phone']:isNumberAvailable(phoneNumber) ~= true

    elseif Cfg.Phone == 'yseries' then
        local data = exports.yseries:GetPlayerSourceIdByIdentifier(identifier)
        return data ~= nil and data ~= false

    elseif Cfg.Phone == '17mov_Phone' then
        local data = exports['17mov_Phone']:GetIdentifierFromNumber(phoneNumber)
        return data ~= nil and data ~= false

    elseif Cfg.Phone == 'other' then
        -- Implement custom logic for other phone systems here.
        -- Return true if the phone number exists, false otherwise.
    end

    return false
end

-- Set a players phone number.
--- @param source number The players source.
--- @param newNumber string The new phone number to set.
function SetPhoneNumber(source, newNumber)
    if Cfg.Phone == 'esx_phone' then
        local identifier = GetIdentifier(source)
        DB.exec('UPDATE phone_number SET phone_number = ? WHERE identifier = ?', {newNumber, identifier})

    elseif Cfg.Phone == 'gcphone' then
        -- Feature not supported by phone.

    elseif Cfg.Phone == 'gksphone' then
        local oldNumber = GetPhoneNumber(source)
        local phoneData = exports.gksphone:GetPhoneDataByNumber(oldNumber)
        exports.gksphone:ChangeNumber(phoneData.phoneID, oldNumber, newNumber, true)

    elseif Cfg.Phone == 'high-phone' then
        -- Feature not supported by phone.

    elseif Cfg.Phone == 'lb-phone' then
        -- Feature not supported by phone.

    elseif Cfg.Phone == 'npwd' then
        if Cfg.Framework == 'esx' then
            local identifier = GetIdentifier(source)
            DB.exec('UPDATE users SET phone_number = ? WHERE identifier = ?', {newNumber, identifier})

        elseif Cfg.Framework == 'qbcore' then
            local Player = GetPlayer(source)
            if Player then
                Player.Functions.SetPhoneNumber(newNumber)
                Player.PlayerData.charinfo.phone = newNumber
                Player.Functions.SavePlayerData()
            end
        end

    elseif Cfg.Phone == 'ns_Phone' then
        exports.ns_Phone:SetPhoneNumber(source, newNumber)

    elseif Cfg.Phone == 'okokPhone' then
        -- Feature not supported by phone.

    elseif Cfg.Phone == 'qb-phone' then
        local Player = GetPlayer(source)
        if Player then
            Player.Functions.SetPhoneNumber(newNumber)
            Player.PlayerData.charinfo.phone = newNumber
            Player.Functions.SavePlayerData()
        end

    elseif Cfg.Phone == 'qbx_npwd' then
        local Player = GetPlayer(source)
        if Player then
            Player.Functions.SetPhoneNumber(newNumber)
            Player.PlayerData.charinfo.phone = newNumber
            Player.Functions.SavePlayerData()
        end

    elseif Cfg.Phone == 'qs-smartphone' then
        -- Feature not supported by phone.

    elseif Cfg.Phone == 'qs-smartphone-pro' then
        -- Feature not supported by phone.

    elseif Cfg.Phone == 'roadphone' then
        -- Feature not supported by phone.

    elseif Cfg.Phone == 'sd-phone' then
        exports['sd-phone']:setSimNumber(source, newNumber)

    elseif Cfg.Phone == 'yseries' then
        local imei = exports.yseries:GetPhoneImeiBySourceId(source)
        exports.yseries:ChangePhoneNumber(imei, newNumber)

    elseif Cfg.Phone == '17mov_Phone' then
        -- Feature not supported by phone.

    elseif Cfg.Phone == 'other' then
        -- Implement custom logic for other phone systems here.
    end
end