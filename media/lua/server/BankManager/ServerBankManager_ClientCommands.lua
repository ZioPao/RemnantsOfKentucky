require "PZ_EFT_debugtools"

local MODULE = 'PZEFT-BankAccount'

local ClientCommands = {}

--- Sends command to client to set the player's safehouse
---@param playerObj IsoPlayer
---@param args Table {isInitialise=true/false} 
ClientCommands.RequestBankAccount = function(playerObj, args)
    args = args or {}
    local account = ServerBankManager.getOrCreateAccount(playerObj:getUsername(), args.isInitialise)
    sendServerCommand(playerObj, MODULE, 'UpdateBankAccount', {account=account})
end

--- Process a transaction and do a callback if successful or failed.
--- Also calls the RequestBankAccount->UpdateBankAccount command
---@param args {amount=x, onSuccess = {callbackModule="abc", callbackCommand="abc", callbackArgs={args...}}, onFail = {callbackModule="abc", callbackCommand="abc", callbackArgs={args...}}}
ClientCommands.ProcessTransaction = function(playerObj, args)
    --amount, callbackCommand, callbackArgs
    local result = ServerBankManager.processTransaction(playerObj:getUsername(), args.amount)

    if result.success then
        if args.onSuccess and args.callbackModule and args.callbackCommand then
            sendServerCommand(playerObj, args.onSuccess.callbackModule, args.onSuccess.callbackCommand, args.onSuccess.callbackArgs)
        end
    else
        if args.onFail and args.callbackModule and args.callbackCommand then
            sendServerCommand(playerObj, args.onFail.callbackModule, args.onFail.callbackCommand, args.onFail.callbackArgs)
        end
    end

    ClientCommands.RequestBankAccount(playerObj, nil)
end

local OnClientCommand = function(module, command, playerObj, args)
    if module == MODULE and ClientCommands[command] then
        debugPrint("Client Command - " .. MODULE .. "." .. command)
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)
