--- @param job string The job name for the society account, for example 'mechanic' for a mechanic society.
--- @param societyLabel string The label for the society account, only used for esx.
function LoadSocietyAccount(job, societyLabel)
    if Cfg.Society == 'none' then return end

    if Cfg.Society == 'esx_society' then
        local accountName = 'society_'..job
        if not exports.esx_society:GetSociety(job) then
            exports.esx_society:registerSociety(job, societyLabel, accountName, accountName, accountName)
            exports.esx_addonaccount:AddSharedAccount({name = accountName, label = societyLabel}, 0)
        end

    elseif Cfg.Society == 'fd_banking' then
        if not exports.fd_banking:GetAccount(job) then
            ERROR('3485', 'fd_banking society account for job '..job..' does not exist.')
        end

    elseif Cfg.Society == 'ns_SolarBanking' then
        exports.ns_SolarBanking:EnsureSociety(job, societyLabel)

    elseif Cfg.Society == 'okokBanking' then
        if not exports.okokBanking:GetAccount(job) then
            ERROR('3485', 'okokBanking society account for job '..job..' does not exist.')
        end

    elseif Cfg.Banking == 'p_banking' then
        if not exports.p_banking:getAccountMoney(job) then
            ERROR('3485', 'p_banking society account for job '..job..' does not exist.')
        end

    elseif Cfg.Society == 'qb-banking' then
        if not exports['qb-banking']:GetAccount(job) then
            exports['qb-banking']:CreateJobAccount(job, 0)
        end

    elseif Cfg.Society == 'Renewed-Banking' then
        if not exports['Renewed-Banking']:getAccountMoney(job) then
            exports['Renewed-Banking']:CreateJobAccount({name = job, label = societyLabel}, 0)
        end

    elseif Cfg.Society == 'RxBanking' then
        if not exports.RxBanking:GetSocietyAccount(job) then
            ERROR('3485', 'RxBanking society account for job '..job..' does not exist.')
        end

    elseif Cfg.Society == 'tgg-banking' then
        if not exports['tgg-banking']:GetSocietyAccount(job) then
            exports['tgg-banking']:CreateBusinessAccount(job, 0, societyLabel, 'green')
        end

    elseif Config.Society == 'tgiann-bank' then
        if not exports['tgiann-bank']:GetJobAccountBalance(job) then
            ERROR('3485', 'tgiann-bank society account for job '..job..' does not exist.')
        end

    elseif Cfg.Society == 'wasabi_banking' then
        if not exports.wasabi_banking:GetAccountBalance(job, 'society') then
            exports.wasabi_banking:CreateJobAccount(job, 0)
        end

    elseif Config.Society == 'other' then
        -- add your own society loading here, make sure to check if the society already exists before creating it to avoid duplicates.
    end
end

--- @param job string The job name for the society account, for example 'mechanic' for a mechanic society.
--- @return table|nil # A table containing information about the society account, such as balance and other relevant details. The exact structure of the returned table may vary depending on the society system used.
function GetSociety(job)
    if Cfg.Society == 'none' then return nil end

    if Cfg.Society == 'esx_society' then
        local society = exports.esx_society:GetSociety(job)
        local result = nil
        TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function(account)
            if account then
                result = account
            end
        end)
        return result

    elseif Cfg.Society == 'fd_banking' then
        local balance = exports.ns_SolarBanking:GetSocietyMoney(job)
        if balance == nil then return nil end
        return {
            account = job,
            balance = balance,
        }

    elseif Cfg.Society == 'ns_SolarBanking' then
        local balance = exports.okokBanking:GetAccount(job)
        if balance == nil then return nil end
        return {
            account = job,
            balance = balance,
        }

    elseif Cfg.Society == 'okokBanking' then
        local balance = exports.okokBanking:GetAccount(job)
        if balance == nil then return nil end
        return {
            account = job,
            balance = balance,
        }

    elseif Cfg.Banking == 'p_banking' then
        local balance = exports.p_banking:getAccountMoney(job)
        if balance == nil then return nil end
        return {
            account = job,
            balance = balance,
        }

    elseif Cfg.Society == 'qb-banking' then
        return exports['qb-banking']:GetAccount(job)

    elseif Cfg.Society == 'Renewed-Banking' then
        local balance = exports['Renewed-Banking']:getAccountMoney(job)
        if balance == nil then return nil end
        return {
            account = job,
            balance = balance,
        }

    elseif Cfg.Society == 'RxBanking' then
        return exports.RxBanking:GetSocietyAccount(job)

    elseif Cfg.Society == 'tgg-banking' then
        return exports['tgg-banking']:GetSocietyAccount(job)

    elseif Config.Society == 'tgiann-bank' then
        local balance = exports['tgiann-bank']:GetJobAccountBalance(job)
        if balance == nil then return nil end
        return {
            account = job,
            balance = balance,
        }

    elseif Cfg.Society == 'wasabi_banking' then
        local balance = exports.wasabi_banking:GetAccountBalance(job, 'society')
        if balance == nil then return nil end
        return {
            account = job,
            balance = balance,
        }

    elseif Config.Society == 'other' then
        -- add your own society balance retrieval here.
        return {}
    end

    return nil
end

--- @param job string The job name for the society account, for example 'mechanic' for a mechanic society.
--- @return number # The current balance of the society account.
function GetSocietyBalance(job)
    if Cfg.Society == 'none' then return 0 end

    local society = GetSociety(job)
    if not society then return 0 end

    if Cfg.Society == 'esx_society' then
        return society.money

    elseif Cfg.Society == 'fd_banking' then
        return society.balance

    elseif Cfg.Society == 'ns_SolarBanking' then

    elseif Cfg.Society == 'okokBanking' then
        return society.balance

    elseif Cfg.Banking == 'p_banking' then
        return society.balance

    elseif Cfg.Society == 'qb-banking' then
        return society.account_balance

    elseif Cfg.Society == 'Renewed-Banking' then
        return society.balance

    elseif Cfg.Society == 'RxBanking' then
        return society.balance

    elseif Cfg.Society == 'tgg-banking' then
        return society.balance

    elseif Config.Society == 'tgiann-bank' then
        return society.balance

    elseif Cfg.Society == 'wasabi_banking' then
        return society.balance

    elseif Config.Society == 'other' then
        -- add your own society balance retrieval here.
        return 0
    end

    return 0
end

--- @param job string The job name for the society account, for example 'mechanic' for a mechanic society.
--- @param amount number The amount of money to add to the society account.
--- @param reason string|nil The reason for adding money to the society account.
--- @return boolean # If the money was added successfully, false otherwise.
function AddSocietyMoney(job, amount, reason)
    if Cfg.Society == 'none' then return false end
    reason = reason or Locale('unknown')

    if Cfg.Society == 'esx_society' then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..job, function(account)
			return account.addMoney(amount)
		end)

    elseif Cfg.Society == 'fd_banking' then
        return exports.fd_banking:AddMoney(job, amount, reason)

    elseif Cfg.Society == 'ns_SolarBanking' then
        exports.ns_SolarBanking:AddSocietyMoney(job, amount, reason)

    elseif Cfg.Society == 'okokBanking' then
        return exports.okokBanking:AddMoney(job, amount)

    elseif Cfg.Banking == 'p_banking' then
        return exports.p_banking:addAccountMoney(job, amount)

    elseif Cfg.Society == 'qb-banking' then
        return exports['qb-banking']:AddMoney(job, amount, reason)

    elseif Cfg.Society == 'Renewed-Banking' then
        return exports['Renewed-Banking']:addAccountMoney(job, amount)

    elseif Cfg.Society == 'RxBanking' then
        return exports.RxBanking:AddSocietyMoney(job, amount, 'deposit', reason)

    elseif Cfg.Society == 'tgg-banking' then
        return exports['tgg-banking']:AddSocietyMoney(job, amount)

    elseif Config.Society == 'tgiann-bank' then
        return exports['tgiann-bank']:AddJobMoney(job, amount)

    elseif Config.Society == 'wasabi_banking' then
        return exports.wasabi_banking:AddMoney('society', job, amount)

    elseif Config.Society == 'other' then
        -- add your own society money adding here.
    end
    return false
end

--- @param job string The job name for the society account, for example 'mechanic' for a mechanic society.
--- @param amount number The amount of money to remove to the society account.
--- @param reason string|nil The reason for removing money to the society account.
--- @return boolean # If the money was removed successfully, false otherwise.
function RemoveSocietyMoney(job, amount, reason)
    if Cfg.Society == 'none' then return false end
    reason = reason or Locale('unknown')

    local balance = GetSocietyBalance(job)
    if balance <= amount then
        return false
    end

    if Cfg.Society == 'esx_society' then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..job, function(account)
            return account.removeMoney(amount)
        end)

    elseif Cfg.Society == 'fd_banking' then
        return exports.fd_banking:RemoveMoney(job, amount, reason)

    elseif Cfg.Society == 'ns_SolarBanking' then
        exports.ns_SolarBanking:RemoveSocietyMoney(job, amount, reason)

    elseif Cfg.Society == 'okokBanking' then
        return exports.okokBanking:RemoveMoney(job, amount)

    elseif Cfg.Banking == 'p_banking' then
        return exports.p_banking:removeAccountMoney(job, amount)

    elseif Cfg.Society == 'qb-banking' then
        return exports['qb-banking']:RemoveMoney(job, amount, reason)

    elseif Cfg.Society == 'Renewed-Banking' then
        return exports['Renewed-Banking']:removeAccountMoney(job, amount)

    elseif Cfg.Society == 'RxBanking' then
        return exports.RxBanking:RemoveSocietyMoney(job, amount, 'payment', reason)

    elseif Cfg.Society == 'tgg-banking' then
        return exports['tgg-banking']:RemoveSocietyMoney(job, amount)

    elseif Config.Society == 'tgiann-bank' then
        return exports['tgiann-bank']:RemoveJobMoney(job, amount)

    elseif Config.Society == 'wasabi_banking' then
        return exports.wasabi_banking:RemoveMoney('society', job, amount)

    elseif Config.Society == 'other' then
        -- remove your own society money adding here.
    end
    return false
end