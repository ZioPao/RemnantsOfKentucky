if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then
    return
end

require "PZ_EFT_debugtools"
require "TeleportManager"

local MatchHandler = {}

local Countdown = require("Time/PZEFT_Countdown")
local Timer = require("Time/PZEFT_Timer")

function MatchHandler:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.pvpInstance = PvpInstanceManager.getNextInstance()

    MatchHandler.instance = o

    return o
end

function MatchHandler:initialise()
    if self.instance == nil then
        debugPrint("PZ_EFT: No more instances found!")
        MatchHandler.instance = nil
        return
    end

    self:start()
end

---Setup teleporting players to their spawn points
function MatchHandler:start()
    print("Starting match!")
    PvpInstanceManager.teleportPlayersToInstance()

    -- * Start timer and the event handling zombie spawning
    Countdown.Setup(PZ_EFT_CONFIG.MatchSettings.roundTime, function()
        print("Ending the round!")
        self:stopMatch()
    end)


    -- Reopens the panel on the clients
    --sendServerCommand("PZEFT-Time", "OpenTimePanel", {})

    -- self.timer = TimerHandler.Setup(30, 5, self.handleZombieSpawns)

    -- self.timer = TimerHandler:new()
    -- self.timer:setFuncToRun(self.handleZombieSpawns, 5) -- will be run every 5 minnutes
    -- self.timer:initialise()
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
    --TODO PAO: Look at client/ClientMatchHandlers/ExtractionHandler to check for when player enters/exists extraction zone. Subscribe to event if needed.
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
    return MatchHandler.instance
end

return MatchHandler
