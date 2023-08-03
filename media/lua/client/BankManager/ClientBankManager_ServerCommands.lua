require "PZ_EFT_debugtools"

local MODULE = 'PZEFT-BankAccount'

local ServerCommands = {}

--- Update bank account information with data from server
ServerCommands.UpdateBankAccount = function(args)
    if not args then print('ERROR: ServerCommands.UpdateBankAccount - Tried to update bank account without ARGS') return end

    local md = PZEFT_UTILS.GetPlayerModData()
    md.accountBalance = args.account
end

local OnServerCommand = function(module, command, args)
    if module == MODULE and ServerCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)
