--[[
    Banking provider helper for client adapters.
    Creates a basic client adapter factory.
]]

local function createClientBankingAdapter(name, resource, options)
    options = options or {}
    local adapter = {
        name = name,
        resource = resource,
        capabilities = options.capabilities or {
            getAccounts = true,
            getAccountBalance = true,
            hasAccessToAccount = true,
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

    function adapter:openBankingMenu(accountId)
        if options.openBankingMenu then return options.openBankingMenu(self, accountId) end
        return false, { reason = 'unsupported', operation = 'openBankingMenu', provider = self.name }
    end

    function adapter:openATM()
        if options.openATM then return options.openATM(self) end
        return false, { reason = 'unsupported', operation = 'openATM', provider = self.name }
    end

    function adapter:openAccount(accountId)
        if options.openAccount then return options.openAccount(self, accountId) end
        return false, { reason = 'unsupported', operation = 'openAccount', provider = self.name }
    end

    function adapter:getAccounts()
        if options.getAccounts then return options.getAccounts(self) end
        return false, { reason = 'unsupported', operation = 'getAccounts', provider = self.name }
    end

    function adapter:getActiveAccount()
        if options.getActiveAccount then return options.getActiveAccount(self) end
        return false, { reason = 'unsupported', operation = 'getActiveAccount', provider = self.name }
    end

    function adapter:getAccountBalance(accountId)
        if options.getAccountBalance then return options.getAccountBalance(self, accountId) end
        return false, { reason = 'unsupported', operation = 'getAccountBalance', provider = self.name }
    end

    function adapter:hasAccessToAccount(accountId)
        if options.hasAccessToAccount then return options.hasAccessToAccount(self, accountId) end
        return false, { reason = 'unsupported', operation = 'hasAccessToAccount', provider = self.name }
    end

    function adapter:getTransactions(accountId, limit)
        if options.getTransactions then return options.getTransactions(self, accountId, limit) end
        return false, { reason = 'unsupported', operation = 'getTransactions', provider = self.name }
    end

    function adapter:getCards(accountId)
        if options.getCards then return options.getCards(self, accountId) end
        return false, { reason = 'unsupported', operation = 'getCards', provider = self.name }
    end

    function adapter:getAccountIBAN(accountId)
        if options.getAccountIBAN then return options.getAccountIBAN(self, accountId) end
        return false, { reason = 'unsupported', operation = 'getAccountIBAN', provider = self.name }
    end

    function adapter:getAccountPIN(accountId)
        if options.getAccountPIN then return options.getAccountPIN(self, accountId) end
        return false, { reason = 'unsupported', operation = 'getAccountPIN', provider = self.name }
    end

    function adapter:setAccountPIN(accountId, pin)
        if options.setAccountPIN then return options.setAccountPIN(self, accountId, pin) end
        return false, { reason = 'unsupported', operation = 'setAccountPIN', provider = self.name }
    end

    function adapter:getCreditScore()
        if options.getCreditScore then return options.getCreditScore(self) end
        return false, { reason = 'unsupported', operation = 'getCreditScore', provider = self.name }
    end

    function adapter:getLoans()
        if options.getLoans then return options.getLoans(self) end
        return false, { reason = 'unsupported', operation = 'getLoans', provider = self.name }
    end

    function adapter:getSavingGoals(accountId)
        if options.getSavingGoals then return options.getSavingGoals(self, accountId) end
        return false, { reason = 'unsupported', operation = 'getSavingGoals', provider = self.name }
    end

    function adapter:openLoanMenu()
        if options.openLoanMenu then return options.openLoanMenu(self) end
        return false, { reason = 'unsupported', operation = 'openLoanMenu', provider = self.name }
    end

    function adapter:openSavingsMenu(accountId)
        if options.openSavingsMenu then return options.openSavingsMenu(self, accountId) end
        return false, { reason = 'unsupported', operation = 'openSavingsMenu', provider = self.name }
    end

    function adapter:getRaw()
        return resource and exports[resource] or nil
    end

    ViceCity.RegisterProvider('banking', name, adapter)
end

ViceCityCreateClientBankingAdapter = createClientBankingAdapter
