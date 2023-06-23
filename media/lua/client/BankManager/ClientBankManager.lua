ClientBankManager = ClientBankManager or {}

--- Get account information by username
---@param username string
ClientBankManager.getAccount = function(username)
    sendClientCommand('PZEFT-BankAccount', "RequestBankAccount", {})
end

--- Add or decreases an amount to a bank account
--- The callback will be the server command that the server will send if transaction is processed successfully
---@param amount integer
---@param successCallbackModule string
---@param successCallbackCommand string
---@param successCallbackArgs table/string/integer
---@param failCallbackModule string
---@param failCallbackCommand string
---@param failCallbackArgs table/string/integer
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