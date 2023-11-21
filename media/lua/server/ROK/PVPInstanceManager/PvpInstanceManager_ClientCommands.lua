if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then
    return
end

require("ROK/DebugTools")
require "ROK/TeleportManager"
local MODULE = EFT_MODULES.PvpInstances
-------------------------------

local ClientCommands = {}

function ClientCommands.GetAmountAvailableInstances()
    local amount = 100 - PvpInstanceManager.GetAmountUsedInstances()
    sendServerCommand(EFT_MODULES.UI, "ReceiveAmountAvailableInstances", {amount = amount})
end

-------------------------------

local OnClientCommand = function(module, command, playerObj, args)
    if module == MODULE and ClientCommands[command] then
        -- debugPrint("Client Command - " .. MODULE .. "." .. command)
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)
