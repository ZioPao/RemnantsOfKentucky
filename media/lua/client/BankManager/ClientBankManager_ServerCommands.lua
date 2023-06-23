require "PZ_EFT_debugtools"

local MODULE = 'PZEFT-BankAccount'

local ServerCommands = {}

ServerCommands.UpdateBankAccount = function(args)
    local player = getPlayer()
    local md = player:getModData()
    md.PZEFT = md.PZEFT or {}
    md.PZEFT.accountBalance = args.account
end

local OnServerCommand = function(module, command, args)
    if module == MODULE and ServerCommands[command] then
        debugPrint("Server Command - " .. MODULE .. "." .. command)
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)
