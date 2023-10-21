if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then return end

ServerBankManager = ServerBankManager or {}

--- Get account information by username
---@param username string
ServerBankManager.getOrCreateAccount = function(username)
    local accounts = ServerData.Bank.GetBankAccounts()
    local account = accounts[username]
    if not account then
        print("ServerBankManager.addAmountToAccount: Account " .. username .. " doesn't exist! Creating one.")

        -- TODO KIM: This means that we need to access md.accountBalance.balance on a client, not md.accountBalance. Is this intended?

        accounts[username] = {balance = 10000}      -- TODO Just for debug, change it back to 0
        account = accounts[username]
    end

    return account
end

--- Add or decreases an amount to a bank account if possible
---@param username string
---@param amount integer
---@return table {success=true/false, amount=updatedAmount}
ServerBankManager.processTransaction = function(username, amount)
    local accounts = ServerData.Bank.GetBankAccounts()

    if not accounts[username] then
        print("ServerBankManager.addAmountToAccount: Account " .. username .. " doesn't exist!")
        return {success = false, account = nil}
    end

    --If amount is decreased
    if amount < 0 and accounts[username].balance + amount < 0 then
        return {success = false, account = accounts[username]}
    end

    accounts[username].balance = accounts[username].balance + amount

    return {success = true, account = accounts[username]}
end
