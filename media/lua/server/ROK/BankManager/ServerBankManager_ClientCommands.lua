if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then return end

require("ROK/DebugTools")
local MODULE = EFT_MODULES.Bank

-----------------------------------------
local ClientCommands = {}

--- Sends command to client to set the player's safehouse
---@param playerObj IsoPlayer
ClientCommands.RequestBankAccount = function(playerObj, _)
    local account = ServerBankManager.getOrCreateAccount(playerObj:getUsername())
    sendServerCommand(playerObj, MODULE, 'UpdateBankAccount', {account=account})
end


---@alias callaback {callbackModule : string, callbackCommand : string, callbackArgs : table}

--- Process a transaction and do a callback if successful or failed.
--- Also calls the RequestBankAccount->UpdateBankAccount command
---@param args {amount : number, onSuccess : callaback, onFail : callaback} {amount=x, onSuccess = {callbackModule="abc", callbackCommand="abc", callbackArgs={args...}}, onFail = {callbackModule="abc", callbackCommand="abc", callbackArgs={args...}}}
ClientCommands.ProcessTransaction = function(playerObj, args)
    --amount, callbackCommand, callbackArgs, inventoryCheck

    --if inventoryCheck then
        --args.item
        --args.quantity
        --args.totalPrice
        
    --end
    -- print("ProcessTransaction")

    -- print("OnSuccess Callback module: " .. tostring(args.onSuccess.callbackModule))
    -- print("OnSuccess Callback command: " .. tostring(args.onSuccess.callbackCommand))

    -- print("OnFail Callback module: " .. tostring(args.onFail.callbackModule))
    -- print("OnFail Callback command: " .. tostring(args.onFail.callbackCommand))

    local result = ServerBankManager.processTransaction(playerObj:getUsername(), args.amount)
    --print("Result from processTransaction " .. tostring(result))
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
    ClientCommands.RequestBankAccount(playerObj, {})
end


--- Sends the full table of Bank accounts to a client, to be used in the leaderboard
---@param playerObj IsoPlayer
ClientCommands.TransmitBankAccounts = function(playerObj, _)
    local accounts = ServerData.Bank.GetBankAccounts()
    sendServerCommand(playerObj, MODULE, 'ReceiveBankAccounts', {accounts=accounts})
end

-----------------------------------------

local OnClientCommand = function(module, command, playerObj, args)
    if module == MODULE and ClientCommands[command] then
        debugPrint("Client Command - " .. MODULE .. "." .. command)
        ClientCommands[command](playerObj, args)
    end
end


Events.OnClientCommand.Add(OnClientCommand)
