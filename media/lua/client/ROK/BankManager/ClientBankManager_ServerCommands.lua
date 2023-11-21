require("ROK/DebugTools")
local MODULE = 'PZEFT-BankAccount'
-------------------

local ServerCommands = {}

--- Update bank account information with data from server
---@param args {account : any}      -- TODO Set the correct param
 function ServerCommands.UpdateBankAccount(args)
    if not args then
        debugPrint('ERROR: ServerCommands.UpdateBankAccount - Tried to update bank account without ARGS')
        return
    end

    local md = PZEFT_UTILS.GetPlayerModData()
    md.bankAccount = args.account
end

--- Receive the updated bank accounts from the server
---@param args {accounts : table}
 function ServerCommands.ReceiveBankAccounts(args)
    if args.accounts then
        debugPrint("Setting accounts")
        LeadearboardPanel.SetBankAccounts(args.accounts)
    end
end

------------------------------------

local OnServerCommand = function(module, command, args)
    if module == MODULE and ServerCommands[command] then
        debugPrint("Server Command - " .. MODULE .. "." .. command)
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)
