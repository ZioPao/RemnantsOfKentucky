if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then
    return
end

require "PZ_EFT_debugtools"
require "TeleportManager"

local MatchHandler = {}

local TimerHandler = require("TimeLogic/Timer")
local CountdownHandler = require("TimeLogic/Countdown")

function MatchHandler:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.pvpInstance = PvpInstanceManager.getNextInstance()

    MatchHandler.currenthandler = o

    return o
end

function MatchHandler:initialise()
    if self.instance == nil then
        debugPrint("PZ_EFT: No more instances found!")
        MatchHandler.currenthandler = nil
        return
    end

    self:start()
end

---Setup teleporting players to their spawn points
function MatchHandler:start()
    PvpInstanceManager.teleportPlayersToInstance()

    -- * Start timer and the event handling zombie spawning
    self.timer = TimerHandler:new()
    self.timer:setFuncToRun(self.handleZombieSpawns, 5) -- will be run every 5 minnutes
    self.timer:initialise()
end

--- Kill players that are still in the pvp instance and didn't manage to escape in time
function MatchHandler:killAlivePlayers()
    local temp = getOnlinePlayers()
    for i = 0, temp:size() - 1 do
        local player = temp:get(i)
        sendServerCommand(player, "PZEFT", "CommitDieIfInRaid", {})
    end
end

--- Extract the player and return to safehouse
---@param playerUsername string
function MatchHandler:extractPlayer(playerUsername)
    local player = getPlayerByUserName(playerUsername)
    SafehouseInstanceManager.sendPlayerToSafehouse(player)
end

function MatchHandler:stopMatch()
    -- Teleport back everyone
    SafehouseInstanceManager.sendPlayersToSafehouse()
    PvpInstanceManager.getNextInstance()
end

function MatchHandler:handleZombieSpawns(currentTime)
    -- TODO We need to manage the zombie spawns depending on the time.
end

-- *********************-

function MatchHandler.GetHandler()
    return MatchHandler.currenthandler
end

return MatchHandler
