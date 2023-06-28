ClientBankManager = ClientBankManager or {}

--- Get account information by username
---@param isInitialise boolean
ClientBankManager.getAccount = function(isInitialise)
    sendClientCommand('PZEFT-BankAccount', "RequestBankAccount", {isInitialise=isInitialise})
end

--- Add or decreases an amount to a bank account
--- The callback will be the server command that the server will send if transaction is processed successfully
---@param amount integer
---@param successCallbackModule string
---@param successCallbackCommand string
---@param successCallbackArgs table
---@param failCallbackModule string
---@param failCallbackCommand string
---@param failCallbackArgs table
ClientBankManager.TryProcessTransaction = function(amount, successCallbackModule, successCallbackCommand,
    successCallbackArgs, failCallbackModule, failCallbackCommand, failCallbackArgs)
    sendClientCommand('PZEFT-BankAccount', "ProcessTransaction", {
        amount = amount,
        onSuccess = {
            callbackModule = successCallbackModule,
            callbackCommand = successCallbackCommand,
            callbackArgs = successCallbackArgs
        },
        onFail = {
            callbackModule = failCallbackModule,
            callbackCommand = failCallbackCommand,
            callbackArgs = failCallbackArgs
        }
    })
end

--- On create player
--- Teleport player to a "neutral"square to remove from any potential safehouse
--- Request safehouse allocation of player from server
---@param player IsoPlayer
ClientBankManager.onCreatePlayer = function(_, player)
	if player == getPlayer() then
        --On join, request safehouse allocation data
        debugPrint("On Create Player, RequestSafehouseAllocation")
        --Request safe house allocation, which in turn will teleport the player to the assigned safehouse
        ClientBankManager.getAccount(true)
    end
end

Events.OnCreatePlayer.Add(ClientBankManager.onCreatePlayer)