--- Requests, updates, etc bank accounts from the client

---@class ClientBankManager
local ClientBankManager = {}

function ClientBankManager.RequestBankAccountFromServer()
    local md = PZEFT_UTILS.GetPlayerModData()
    md.bankAccount = nil
    sendClientCommand(EFT_MODULES.bank, "RequestBankAccount", {})
end

--- Returns account balance from player's mod data
---@return number?
function ClientBankManager.GetPlayerBankAccountBalance()
    local md = PZEFT_UTILS.GetPlayerModData()
    if md.bankAccount and md.bankAccount.balance then
        return md.bankAccount.balance
    else
        return -1
    end
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
function ClientBankManager.TryProcessTransaction(amount, successCallbackModule, successCallbackCommand,
    successCallbackArgs, failCallbackModule, failCallbackCommand, failCallbackArgs)

    sendClientCommand(EFT_MODULES.Bank, "ProcessTransaction", {
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


------------------------------------------------------------------------
--* COMMANDS FROM SERVER *--
------------------------------------------------------------------------

local BankCommands = {}

--- Update bank account information with data from server
---@param args {account : any}      -- TODO Set the correct param
 function BankCommands.UpdateBankAccount(args)
    if not args then
        debugPrint('ERROR: ServerCommands.UpdateBankAccount - Tried to update bank account without ARGS')
        return
    end

    local md = PZEFT_UTILS.GetPlayerModData()
    md.bankAccount = args.account
end

--- Receive the updated bank accounts from the server
---@param args {accounts : table}
 function BankCommands.ReceiveBankAccounts(args)
    if args.accounts then
        debugPrint("Setting accounts")
        LeadearboardPanel.SetBankAccounts(args.accounts)
    end
end

------------------------------------

local function OnBankCommands(module, command, args)
    if module == EFT_MODULES.Bank and BankCommands[command] then
        debugPrint("Server Command - " .. EFT_MODULES.Bank .. "." .. command)
        BankCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnBankCommands)


return ClientBankManager