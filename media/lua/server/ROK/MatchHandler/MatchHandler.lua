if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then
    return
end

require("ROK/DebugTools")
require "ROK/TeleportManager"
local Countdown = require("ROK/Time/Countdown")
---------------------------------------------------

---@class MatchHandler
---@field pvpInstance pvpInstanceTable
local MatchHandler = {}

---Creates new MatchHandler
---@return MatchHandler
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
    debugPrint("Starting match!")
    PvpInstanceManager.teleportPlayersToInstance()  -- TODO this is kinda shaky, we should integrate it here in MatchHandler

    MatchHandler.players = {}
    local temp = getOnlinePlayers()
    for i = 0, temp:size() - 1 do
        local player = temp:get(i)
        -- TODO Consider if they disconnect from server
        -- TODO Consider players which extract
        -- TODO Consider player who died
        table.insert(MatchHandler.players, player)

    end

    -- Start timer and the event handling zombie spawning
    Countdown.Setup(PZ_EFT_CONFIG.MatchSettings.roundTime, function()
        print("Ending the round!")
        self:stopMatch()
    end)

    -- Setup Zombie handling
    Countdown.AddIntervalFunc(PZ_EFT_CONFIG.MatchSettings.zombieIncreaseTime, MatchHandler.HandleZombieSpawns)

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
---@param playerObj IsoPlayer
function MatchHandler:extractPlayer(playerObj)
    --TODO PAO: Look at client/ClientMatchHandlers/ExtractionHandler to check for when player enters/exists extraction zone. Subscribe to event if needed.
    SafehouseInstanceManager.sendPlayerToSafehouse(playerObj)
end

function MatchHandler:stopMatch()
    -- Teleport back everyone
    SafehouseInstanceManager.sendPlayersToSafehouse()
    PvpInstanceManager.getNextInstance()
end

---comment
---@param loops number amount of time that this function has been called by Countdown
function MatchHandler.HandleZombieSpawns(loops)

    -- TODO Find a point in the map where there are no players and then move zombies towards them


    -- TODO Start loop until we can actually trigger a correct spawn
    local onlinePlayers = getOnlinePlayers()
    for i=0, onlinePlayers:size() - 1 do
        local player = onlinePlayers:get(i)

        local x = player:getX()
        local y = player:getY()

        -- We can't go overboard with addedX or addedY
        local randomX = ZombRand(20, 60)
        local randomY = ZombRand(20, 60)

        -- TODO AMount of zombies should scale based on players amount too, to prevent from killing the server
        local zombiesAmount = loops
        debugPrint("spawning " .. zombiesAmount .. " near " .. player:getUsername())
        -- TODO Check if there are players near this area. If so, redo random
        addZombiesInOutfit(x + randomX, y + randomY, 0, loops, "", 50, false, false, false, false, 1)
        addSound(player, math.floor(x), math.floor(y), 0, 300, 100)

    end

end

--------------------------------------------------
--- Get the instance of MatchHandler
---@return MatchHandler
function MatchHandler.GetHandler()
    return MatchHandler.instance
end

return MatchHandler
