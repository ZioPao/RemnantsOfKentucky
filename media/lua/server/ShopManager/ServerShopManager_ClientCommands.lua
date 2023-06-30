if (not isServer()) and not (not isServer() and not isClient()) then return end

require "PZ_EFT_debugtools"

local MODULE = 'PZEFT-Shop'

local ClientCommands = {}

--- Recieve updated shop item list from admin client and transmit it back to all clients
ClientCommands.transmitPrices = function(player, data)
    --TODO: Confirm that player is admin?
    ServerData.Bank.SetShopItems(data)
    ServerData.Bank.TransmitShopItems()
end

local OnClientCommand = function(module, command, playerObj, args)
    if module == MODULE and ClientCommands[command] then
        debugPrint("Client Command - " .. MODULE .. "." .. command)
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)