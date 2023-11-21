if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then return end

require("ROK/DebugTools")
--------------------

local MODULE = EFT_MODULES.Shop
local ClientCommands = {}

--- Receive updated shop item list from admin client and transmit it back to all clients
---@param player IsoPlayer
---@param data any
ClientCommands.TransmitShopItems = function(player, data)
    ServerData.Shop.SetShopItems(data)
    ServerData.Shop.TransmitShopItems()
end

local OnClientCommand = function(module, command, playerObj, args)
    if module == MODULE and ClientCommands[command] then
        debugPrint("Client Command - " .. MODULE .. "." .. command)
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)
