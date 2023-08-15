require "PZ_EFT_debugtools"

local MODULE = 'PZEFT-BankAccount'

local ServerCommands = {}

--- Update bank account information with data from server
ServerCommands.UpdateBankAccount = function(args)
    if not args then print('ERROR: ServerCommands.UpdateBankAccount - Tried to update bank account without ARGS') return end

    local md = PZEFT_UTILS.GetPlayerModData()
    md.accountBalance = args.account
end


--- Receive the updated bank accounts from the server
---@param args table {accounts=accounts}
ServerCommands.ReceiveBankAccounts = function(args)
    if args.accounts then
        print("Setting accounts")
        LeadearboardPanel.SetBankAccounts(args.accounts)
    end
end

local OnServerCommand = function(module, command, args)
    if module == MODULE and ServerCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)
