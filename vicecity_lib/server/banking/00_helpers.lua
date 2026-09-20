--[[
    Banking provider helper for server adapters.
    Creates a basic server adapter factory.
]]

local function createServerBankingAdapter(name, resource, options)
    options = options or {}
    local adapter = {
        name = name,
        resource = resource,
        capabilities = options.capabilities or {
            createAccount = true,
            getAccount = true,
            getAccounts = true,
            getAccountBalance = true,
            addMoney = true,
            removeMoney = true,
            transferMoney = true,
        },
    }

    local function invoke(method, ...)
        if not resource then return false, 'no_resource' end
        local arguments = { ... }
        local ok, first, second = pcall(function()
            return exports[resource][method](table.unpack(arguments))
        end)
        if not ok then return false, second or first end
        return first, second
    end

    function adapter:createAccount(accountType, name, label, owner)
        if options.createAccount then return options.createAccount(self, accountType, name, label, owner) end
        return false, { reason = 'unsupported', operation = 'createAccount', provider = self.name }
    end

    function adapter:ensureAccount(accountType, name, label, owner)
        if options.ensureAccount then return options.ensureAccount(self, accountType, name, label, owner) end
        if options.createAccount then return options.createAccount(self, accountType, name, label, owner) end
        return false, { reason = 'unsupported', operation = 'ensureAccount', provider = self.name }
    end

    function adapter:getAccount(accountId)
        if options.getAccount then return options.getAccount(self, accountId) end
        return false, { reason = 'unsupported', operation = 'getAccount', provider = self.name }
    end

    function adapter:getAccounts(owner, accountType)
        if options.getAccounts then return options.getAccounts(self, owner, accountType) end
        return false, { reason = 'unsupported', operation = 'getAccounts', provider = self.name }
    end

    function adapter:getAccountBalance(accountId)
        if options.getAccountBalance then return options.getAccountBalance(self, accountId) end
        return false, { reason = 'unsupported', operation = 'getAccountBalance', provider = self.name }
    end

    function adapter:addMoney(accountId, amount, reason, source)
        if options.addMoney then return options.addMoney(self, accountId, amount, reason, source) end
        return false, { reason = 'unsupported', operation = 'addMoney', provider = self.name }
    end

    function adapter:removeMoney(accountId, amount, reason, source)
        if options.removeMoney then return options.removeMoney(self, accountId, amount, reason, source) end
        return false, { reason = 'unsupported', operation = 'removeMoney', provider = self.name }
    end

    function adapter:transferMoney(fromAccountId, toAccountId, amount, reason, source)
        if options.transferMoney then return options.transferMoney(self, fromAccountId, toAccountId, amount, reason,
                source) end
        return false, { reason = 'unsupported', operation = 'transferMoney', provider = self.name }
    end

    function adapter:deposit(accountId, amount, reason, source)
        if options.deposit then return options.deposit(self, accountId, amount, reason, source) end
        return self:addMoney(accountId, amount, reason, source)
    end

    function adapter:withdraw(accountId, amount, reason, source)
        if options.withdraw then return options.withdraw(self, accountId, amount, reason, source) end
        return self:removeMoney(accountId, amount, reason, source)
    end

    function adapter:hasAccessToAccount(source, accountId, role)
        if options.hasAccessToAccount then return options.hasAccessToAccount(self, source, accountId, role) end
        return false, { reason = 'unsupported', operation = 'hasAccessToAccount', provider = self.name }
    end

    function adapter:addAccountUser(accountId, identifier, role)
        if options.addAccountUser then return options.addAccountUser(self, accountId, identifier, role) end
        return false, { reason = 'unsupported', operation = 'addAccountUser', provider = self.name }
    end

    function adapter:removeAccountUser(accountId, identifier)
        if options.removeAccountUser then return options.removeAccountUser(self, accountId, identifier) end
        return false, { reason = 'unsupported', operation = 'removeAccountUser', provider = self.name }
    end

    function adapter:setAccountRole(accountId, identifier, role)
        if options.setAccountRole then return options.setAccountRole(self, accountId, identifier, role) end
        return false, { reason = 'unsupported', operation = 'setAccountRole', provider = self.name }
    end

    function adapter:getAccountUsers(accountId)
        if options.getAccountUsers then return options.getAccountUsers(self, accountId) end
        return false, { reason = 'unsupported', operation = 'getAccountUsers', provider = self.name }
    end

    function adapter:getTransactions(accountId, limit)
        if options.getTransactions then return options.getTransactions(self, accountId, limit) end
        return false, { reason = 'unsupported', operation = 'getTransactions', provider = self.name }
    end

    function adapter:addTransaction(accountId, sender, receiver, amount, txType, reason, source)
        if options.addTransaction then return options.addTransaction(self, accountId, sender, receiver, amount, txType,
                reason, source) end
        return false, { reason = 'unsupported', operation = 'addTransaction', provider = self.name }
    end

    function adapter:createJobAccount(job, label)
        if options.createJobAccount then return options.createJobAccount(self, job, label) end
        return false, { reason = 'unsupported', operation = 'createJobAccount', provider = self.name }
    end

    function adapter:createGangAccount(gang, label)
        if options.createGangAccount then return options.createGangAccount(self, gang, label) end
        return false, { reason = 'unsupported', operation = 'createGangAccount', provider = self.name }
    end

    function adapter:createBusinessAccount(businessId, label, owner)
        if options.createBusinessAccount then return options.createBusinessAccount(self, businessId, label, owner) end
        return false, { reason = 'unsupported', operation = 'createBusinessAccount', provider = self.name }
    end

    function adapter:deleteAccount(accountId)
        if options.deleteAccount then return options.deleteAccount(self, accountId) end
        return false, { reason = 'unsupported', operation = 'deleteAccount', provider = self.name }
    end

    function adapter:getRaw()
        return resource and exports[resource] or nil
    end

    ViceCity.RegisterProvider('banking', name, adapter)
end

ViceCityCreateServerBankingAdapter = createServerBankingAdapter
