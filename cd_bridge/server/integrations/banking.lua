--- @param source number The player source.
--- @param amount number The amount of the transaction.
--- @param money_type 'cash' | 'bank' | string The type of money involved in the transaction.
--- @param reason string|nil The reason for the transaction. 
--- @param transaction_type 'deposit' | 'withdraw' | string The type of transaction.
function LogTransaction(source, amount, money_type, reason, transaction_type)
    if Cfg.Banking == 'none' then return end
    if money_type == 'cash' then return end

    local identifier = GetIdentifier(source)
    local resourceName = GetCurrentResourceName()
    local characterName = GetCharacterName(source)
    local accountLabel = 'Personal Account / ' .. identifier

    if Cfg.Banking == 'esx_banking' then
        exports.esx_banking:logTransaction(source, reason, transaction_type, amount)

    elseif Cfg.Banking == 'fd_banking' then
        exports.fd_banking:doTransfer(source, source, nil, amount, nil, reason, nil, false)

    elseif Cfg.Banking == 'ns_SolarBanking' then
        local formatAmount = transaction_type == 'withdraw' and -amount or amount
        exports.ns_SolarBanking:AddTransactionLog(identifier, formatAmount, reason, transaction_type)

    elseif Cfg.Banking == 'okokBanking' then
        local data = {
            sender_identifier = transaction_type == 'deposit' and resourceName or identifier,
            sender_name = transaction_type == 'deposit' and resourceName or characterName,
            receiver_identifier = transaction_type == 'deposit' and identifier or resourceName,
            receiver_name = transaction_type == 'deposit' and characterName or resourceName,
            value = amount,
            type = transaction_type,
            reason = reason
        }
        pcall(function()
            exports.okokBanking:AddTransaction(identifier, data, source)
        end)

    elseif Cfg.Banking == 'omes_banking' then
        exports.omes_banking:LogCustomTransaction(
            source,
            transaction_type == 'withdraw' and 'withdrawal' or transaction_type,
            amount,
            reason
        )

    elseif Cfg.Banking == 'p_banking' then
        local data = {
            iban = identifier,
            type = transaction_type == 'withdraw' and 'outcome' or 'income',
            amount = amount,
            title = reason,
            from = transaction_type == 'deposit' and 'SYSTEM' or characterName,
            to = transaction_type == 'deposit' and characterName or 'SYSTEM'
        }
        exports.p_banking:createHistory(data)

    elseif Cfg.Banking == 'ps-banking' then
        DB.exec('INSERT INTO ps_banking_transactions (identifier, description, type, amount, date, isIncome) VALUES (@identifier, @description, @type, @amount, NOW(), @isIncome)', {
            ['@identifier'] = identifier,
            ['@description'] = reason,
            ['@type'] = transaction_type,
            ['@amount'] = amount,
            ['@isIncome'] = transaction_type == 'deposit' and 1 or 0
        })

    elseif Cfg.Banking == 'qb-banking' then
        exports['qb-banking']:CreateBankStatement(source, accountLabel, amount, reason, transaction_type, 'player')

    elseif Cfg.Banking == 'Renewed-Banking' then
        exports['Renewed-Banking']:handleTransaction(
            identifier,
            accountLabel,
            amount,
            reason,
            transaction_type == 'deposit' and resourceName or characterName, -- sender
            transaction_type == 'deposit' and characterName or resourceName, -- receiver
            transaction_type
        )

    elseif Cfg.Banking == 'RxBanking' then
        exports.RxBanking:CreateTransaction(amount, transaction_type, nil, nil, reason)


    elseif Cfg.Banking == 'tgg-banking' then
        local iAccount = exports['tgg-banking']:GetPersonalAccountByPlayerId(source)
        local myIban = iAccount and iAccount.iban

        exports['tgg-banking']:AddTransaction(
            transaction_type == 'deposit' and myIban or nil,
            transaction_type == 'withdraw' and myIban or nil,
            transaction_type,
            amount,
            reason
        )

    elseif Cfg.Banking == 'wasabi_banking' then
        exports.wasabi_banking:Transaction(
            identifier,
            reason,
            amount,
            transaction_type == 'withdrawal' and 'sent' or 'deposit',
            'personal'
        )

    elseif Config.Banking == 'other' then
        -- add your own transaction logging here.
        return
    end

    return
end

