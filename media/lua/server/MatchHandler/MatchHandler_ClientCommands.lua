if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then
    return
end

require "PZ_EFT_debugtools"
require "TeleportManager"

local MODULE = 'PZEFT-PvpInstances'
local MatchHandler = require("MatchHandler/MatchHandler")

local ClientCommands = {}

function ClientCommands.RequestExtraction(playerObj, args)
    local instance = MatchHandler.instance
    if instance == nil then return end
    instance:extractPlayer(playerObj)
end


local OnClientCommand = function(module, command, playerObj, args)
    if module == MODULE and ClientCommands[command] then
        -- debugPrint("Client Command - " .. MODULE .. "." .. command)
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)
