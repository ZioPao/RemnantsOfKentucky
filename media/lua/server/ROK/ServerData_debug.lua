if not isServer() then return end
local ServerShopManager = require("ROK/Economy/ServerShopManager")
local PvpInstanceManager = require("ROK/PvpInstanceManager")

-----------------

local MODULE = 'SERVER_DEBUG'

local ClientCommands = {}

ClientCommands.loadNewInstances = function()
    PvpInstanceManager.LoadPvpInstances()
end

ClientCommands.getNextInstance = function()
    PvpInstanceManager.GetNextInstance()
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

ClientCommands.TeleportPlayersToInstance = function()
    PvpInstanceManager.TeleportPlayersToInstance()
end

ClientCommands.sendPlayersToSafehouse = function()
    SafehouseInstanceManager.SendPlayersToSafehouse()
end

ClientCommands.loadShopPrices = function()
    ServerShopManager.LoadShopPrices()
end

---------------
local OnClientCommand = function(module, command, playerObj, args)
    if module == MODULE and ClientCommands[command] then
        debugPrint("Client Command - " .. MODULE .. "." .. command)
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)