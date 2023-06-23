require "PZ_EFT_debugtools"

local MODULE = 'PZEFT-BankAccount'

local ClientCommands = {}

--- Sends command to client to set the player's safehouse
---@param playerObj IsoPlayer
ClientCommands.RequestBankAccount = function(playerObj, _)
    local account = ServerBankManager.getAccount(playerObj:getUsername())
    sendServerCommand(playerObj, MODULE, 'UpdateBankAccount', account)
end

--- Process a transaction and do a callback if successful.
--- Also returns the updated bank account balance when successful
---@param args {amount=x, callbackModule="abc", callbackCommand="abc", callbackArgs={args...}}
ClientCommands.ProcessTransaction = function(playerObj, args)
    --amount, callbackCommand, callbackArgs
    local result = ServerBankManager.processTransaction(playerObj:getUsername(), args.amount)

    if result.success then
        if args.callbackModule and args.callbackCommand then
            sendServerCommand(playerObj, args.callbackModule, args.callbackCommand, args.callbackArgs)
        end
        sendServerCommand(playerObj, MODULE, 'UpdateBankAccount', args.account)
    else
        sendServerCommand(playerObj, MODULE, 'TransactionFailed', args)
    end
end

local OnClientCommand = function(module, command, playerObj, args)
    if module == MODULE and ClientCommands[command] then
        debugPrint("Client Command - " .. MODULE .. "." .. command)
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)
