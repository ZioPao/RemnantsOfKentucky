if not isServer() then return end
require "ROK/ServerData"
------------------------------

---@class ServerBankManager
local ServerBankManager =  {}

---comment
---@param username string
---@return bankPlayerTable
local function CreateAccountTable(username)
    return {
        username = username,
        balance = PZ_EFT_CONFIG.Default.balance
    }
end


--- Get account information by username
---@param username string
function ServerBankManager.GetOrCreateAccount(username)
    local bankAccounts = ServerData.Bank.GetBankAccounts()
    if not bankAccounts[username] then
        debugPrint("ServerBankManager.addAmountToAccount: Account " .. username .. " doesn't exist! Creating one.")
        bankAccounts[username] = CreateAccountTable(username)
        ServerData.Bank.SetBankAccounts(bankAccounts)
    end
    return bankAccounts[username]
end

--- Add or decreases an amount to a bank account if possible
---@param username string
---@param amount integer
---@return {success : boolean, account : string}
function ServerBankManager.ProcessTransaction (username, amount)
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

------------------------------------------------------------------------
--* COMMANDS FROM CLIENTS *--
------------------------------------------------------------------------

local BankCommands = {}

---Set a bank account for the player
---@param playerObj IsoPlayer
function BankCommands.SetBankAccount(playerObj)
    local username = playerObj:getUsername()

    -- Get Bank accounts and re-set them
    local bankAccounts = ServerData.Bank.GetBankAccounts()
    bankAccounts[username] = CreateAccountTable(username)
    ServerData.Bank.SetBankAccounts(bankAccounts)
end

--- Sends command to client to set the player's safehouse
---@param playerObj IsoPlayer
function BankCommands.SendBankAccount(playerObj)
    local account = ServerBankManager.GetOrCreateAccount(playerObj:getUsername())
    debugPrint("Running SendBankAccount")
    --PZEFT_UTILS.PrintTable(account)
    sendServerCommand(playerObj, EFT_MODULES.Bank, 'GetBankAccount', {account=account})
end


---@alias callaback {callbackModule : string, callbackCommand : string, callbackArgs : table}

--- Process a transaction and do a callback if successful or failed.
--- Also calls the SendBankAccount -> GetBankAccount command from server to client
---@param args {amount : number, onSuccess : callaback, onFail : callaback} {amount=x, onSuccess = {callbackModule="abc", callbackCommand="abc", callbackArgs={args...}}, onFail = {callbackModule="abc", callbackCommand="abc", callbackArgs={args...}}}
function BankCommands.ProcessTransaction(playerObj, args)
    local result = ServerBankManager.ProcessTransaction(playerObj:getUsername(), args.amount)
    --print("Result from ProcessTransaction " .. tostring(result))
    if result.success then
        print("Transaction success")
        if args.onSuccess and args.onSuccess.callbackModule and args.onSuccess.callbackCommand then
            sendServerCommand(playerObj, args.onSuccess.callbackModule, args.onSuccess.callbackCommand, args.onSuccess.callbackArgs)
        end
    else
        print("Transaction fail")
        if args.onFail and args.onFail.callbackModule and args.onFail.callbackCommand then
            sendServerCommand(playerObj, args.onFail.callbackModule, args.onFail.callbackCommand, args.onFail.callbackArgs)
        end
    end

    --Send updated bank account details to player
    BankCommands.SendBankAccount(playerObj)
end

--- Sends the full table of Bank accounts to a client, to be used in the leaderboard
---@param playerObj IsoPlayer
function BankCommands.TransmitAllBankAccounts(playerObj)
    local accounts = ServerData.Bank.GetBankAccounts()
    sendServerCommand(playerObj, EFT_MODULES.Bank, 'GetAllBankAccounts', {accounts=accounts})
end

-----------------------------------------

local function OnBankCommands(module, command, playerObj, args)
    if module == EFT_MODULES.Bank and BankCommands[command] then
        debugPrint("Client Command - " .. EFT_MODULES.Bank .. "." .. command)
        BankCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnBankCommands)


return ServerBankManager