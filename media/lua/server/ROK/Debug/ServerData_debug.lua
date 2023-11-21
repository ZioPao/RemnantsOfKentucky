require "ROK/ServerData"
require "ROK/PvpInstanceManager/PvpInstanceManager"
-----------------

local MODULE = 'SERVER_DEBUG'

local ClientCommands = {}

ClientCommands.loadNewInstances = function()
    PvpInstanceManager.loadPvpInstances()
end

ClientCommands.getNextInstance = function()
    PvpInstanceManager.getNextInstance()
end

ClientCommands.print_pvp_instances = function()
    ServerData.debug.print_pvp_instances()
end

ClientCommands.print_pvp_usedinstances = function()
    ServerData.debug.print_pvp_usedinstances()
end

ClientCommands.print_pvp_currentinstance = function()
    ServerData.debug.print_pvp_currentinstance()
end

ClientCommands.print_safehouses = function()
    ServerData.debug.print_safehouses()
end

ClientCommands.print_assignedsafehouses = function()
    ServerData.debug.print_assignedsafehouses()
end

ClientCommands.print_bankaccounts = function()
    ServerData.debug.print_bankaccounts()
end

ClientCommands.print_shopitems = function()
    ServerData.debug.print_shopitems()
end

ClientCommands.TransmitShopItems = function()
    ServerShopManager.TransmitShopItems()
end

ClientCommands.teleportPlayersToInstance = function()
    PvpInstanceManager.teleportPlayersToInstance()
end

ClientCommands.sendPlayersToSafehouse = function()
    SafehouseInstanceManager.sendPlayersToSafehouse()
end

ClientCommands.loadShopPrices = function()
    ServerShopManager.LoadShopPrices()
end

---Set a bank account
---@param args {name : string, balance : number}
ClientCommands.setBankAccount = function(args)
    local name = args.name
    local balance = args.balance

    -- Get Bank accounts 
    local bankAccounts = ServerData.Bank.GetBankAccounts()
    bankAccounts[name] = {balance = balance}
    ServerData.Bank.SetBankAccounts(bankAccounts)

end

---------------
local OnClientCommand = function(module, command, playerObj, args)
    if module == MODULE and ClientCommands[command] then
        debugPrint("Client Command - " .. MODULE .. "." .. command)
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)