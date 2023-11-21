if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then
    return
end
require("ROK/DebugTools")
local MatchHandler = require("ROK/MatchHandler/MatchHandler")
-----------------------------

local MODULE = 'PZEFT-PvpInstances'
local ClientCommands = {}

---A client has sent an extraction request
---@param playerObj IsoPlayer player requesting extraction
function ClientCommands.RequestExtraction(playerObj)
    local instance = MatchHandler.GetHandler()
    if instance == nil then return end
    instance:extractPlayer(playerObj)
end

---Removes a player from the current match
---@param playerObj IsoPlayer
function ClientCommands.RemovePlayer(playerObj)
    local instance = MatchHandler.GetHandler()
    if instance == nil then return end
    instance:removePlayerFromMatchList(playerObj:getOnlineID())
    
end

---------------------------------
local OnClientCommand = function(module, command, playerObj, args)
    if module == MODULE and ClientCommands[command] then
        -- debugPrint("Client Command - " .. MODULE .. "." .. command)
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)
