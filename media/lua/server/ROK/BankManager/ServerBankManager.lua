if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then return end

---@class ServerBankManager
ServerBankManager = ServerBankManager or {}

--- Get account information by username
---@param username string
ServerBankManager.getOrCreateAccount = function(username)
    local bankAccounts = ServerData.Bank.GetBankAccounts()
    if not bankAccounts[username] then
        print("ServerBankManager.addAmountToAccount: Account " .. username .. " doesn't exist! Creating one.")
        bankAccounts[username] = {balance = 10000}      -- TODO Just for debug, change it back to 0
    end

    return bankAccounts[username]
end

--- Add or decreases an amount to a bank account if possible
---@param username string
---@param amount integer
---@return {success : boolean, account : string}
ServerBankManager.processTransaction = function(username, amount)
    local bankAccounts = ServerData.Bank.GetBankAccounts()

    if not bankAccounts[username] then
        print("ServerBankManager.addAmountToAccount: Account " .. username .. " doesn't exist!")
        return {success = false, account = nil}
    end

    --If amount is decreased
    if amount < 0 and bankAccounts[username].balance + amount < 0 then
        return {success = false, account = bankAccounts[username]}
    end

    bankAccounts[username].balance = bankAccounts[username].balance + amount

    return {success = true, account = bankAccounts[username]}
end
