if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then return end

require "PZ_EFT_debugtools"
require "TeleportManager"

local MODULE = 'PZEFT-Instances'

local ClientCommands = {}

ClientCommands.OnStartInstance = function()
    --TODO: Teleport players to current instance
end

ClientCommands.OnFinishInstance = function()
    --TODO: Get next instance
end

local OnClientCommand = function(module, command, playerObj, args)
    if module == MODULE and ClientCommands[command] then
        --debugPrint("Client Command - " .. MODULE .. "." .. command)
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)
