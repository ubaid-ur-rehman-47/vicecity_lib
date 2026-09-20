--- @param source number The player source.
--- @param targetSource number The target player source.
--- @param society string The society name (e.g. 'police', 'ambulance', etc.) that the bill is associated with.
--- @param amount number The amount of the bill.
--- @param reason string | nil The reason for the bill.
function SendBillToPlayuer(source, targetSource, society, amount, reason)
    if Cfg.Billing == 'none' then return end

    if not society then return end
    if not amount then return end
    reason = reason or Locale('no_reason_provided')

    local senderIdentifier = GetIdentifier(source)
    local targetIdentifier = GetIdentifier(targetSource)
    local societyLabel = GetJobLabel(society)


    if Cfg.billing == 'codem_billing' then
        exports['codem-billing']:createBilling(source, targetIdentifier, amount, reason, society)

    elseif Cfg.billing == 'codem-billingv2' then
        exports['codem-billingv2']:CreateBillingCustom(targetSource, amount, reason, false, nil, society, nil, nil)

    elseif Cfg.Billing == 'esx_billing' then
        local Player = GetPlayer(source)
        if not Player then return end

        DB.exec('INSERT INTO billing(identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)', {
            ['@identifier'] = targetIdentifier,
            ['@sender'] = senderIdentifier,
            ['@target_type'] = 'society',
            ['@target'] = society,
            ['@label'] = reason,
            ['@amount'] = amount
        })

    elseif Cfg.Billing == 'okokBilling' then
        TriggerEvent('okokBilling:CreateCustomInvoice', targetSource, amount, reason, societyLabel, society, societyLabel, senderIdentifier)

    elseif Cfg.Billing == 'other' then
        -- add your own billing integration here.
    end
end