ClientBankManager = ClientBankManager or {}

--- Get account information by username
---@param username string
ClientBankManager.getAccount = function(username)

end

--- Add or decreases an amount to a bank account
--- The callback will be the server command that the server will send if transaction is processed successfully
---@param amount integer
---@param callbackClientModule string
---@param callbackClientCommand string
---@param callbackClientArgs table/string/integer
ClientBankManager.TryProcessTransaction = function(amount, callbackClientModule, callbackClientCommand, callbackClientArgs)
    sendClientCommand('PZEFT-BankAccount', "ProcessTransaction", {
        amount = amount,
        callbackModule = callbackClientModule,
        callbackCommand = callbackClientCommand,
        callbackArgs = callbackClientArgs
    })
end
