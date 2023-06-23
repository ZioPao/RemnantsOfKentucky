ServerBankManager = ServerBankManager or {}

--- Get account information by username
---@param username string
ServerBankManager.getOrCreateAccount = function(username, isInitialise)
    local accounts = ServerData.Bank.GetBankAccounts()
    local account = accounts[username]
    if not account then
        print("ServerBankManager.addAmountToAccount: Account " .. username .. " doesn't exist!")
        if isInitialise then
            accounts[username] = 0
            account = accounts[username]
        end
    end

    return account
end

--- Add or decreases an amount to a bank account if possible
---@param username string
---@param amount integer
---@return {success=true/false, amount=updatedAmount}
ServerBankManager.processTransaction = function(username, amount)
    local accounts = ServerData.Bank.GetBankAccounts()

    if not accounts[username] then
        print("ServerBankManager.addAmountToAccount: Account " .. username .. " doesn't exist!")
        return {success = false, account = nil}
    end

    --If amount is decreased
    if amount < 0 and accounts[username] + amount < 0 then
        return {success = false, account = accounts[username]}
    end

    accounts[username] = accounts[username] + amount

    return {success = true, account = accounts[username]}
end
