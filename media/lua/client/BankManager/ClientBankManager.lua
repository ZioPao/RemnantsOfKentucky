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

--- On player initialise, request bank account info
---@param player IsoPlayer
ClientBankManager.onPlayerInit = function(player)
    if player and player == getPlayer() then
        local md = player:getModData()
        md.PZEFT = md.PZEFT or {}
        if not md.PZEFT.accountBalance then
            ClientBankManager.getAccount(true)
            Events.OnPlayerUpdate.Remove(ClientBankManager.onPlayerInit)
        end
    end
end

Events.OnPlayerUpdate.Add(ClientBankManager.onPlayerInit)