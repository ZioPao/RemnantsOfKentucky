ClientBankManager = ClientBankManager or {}

--TODO: When opening shop menu, request account
--- Get account information by username
ClientBankManager.requestBankAccountFromServer = function()
    local md = PZEFT_UTILS.GetPlayerModData()
    md.bankAccount = nil

    sendClientCommand('PZEFT-BankAccount', "RequestBankAccount", {})
end

--- Returns account balance from player's mod data
---@return number
ClientBankManager.getPlayerBankAccountBalance = function()
    local md = PZEFT_UTILS.GetPlayerModData()
    return md.bankAccount.balance
end

--- Add or decreases an amount to a bank account
--- The callback will be the server command that the server will send if transaction is processed successfully
--- If inventory check is defined, the server checks for inventory type + quantity
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