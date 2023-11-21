if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then
    return
end

require("ROK/DebugTools")
require "ROK/TeleportManager"
local Countdown = require("ROK/Time/Countdown")
---------------------------------------------------

---@class MatchHandler
---@field pvpInstance pvpInstanceTable
---@field playersInMatch table<number,number>        Table of player ids
local MatchHandler = {}

---Creates new MatchHandler
---@return MatchHandler
function MatchHandler:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.pvpInstance = PvpInstanceManager.getNextInstance()
    o.playersInMatch = {}

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
    PvpInstanceManager.TeleportPlayersToInstance()  -- TODO this is kinda shaky, we should integrate it here in MatchHandler

    local temp = getOnlinePlayers()
    for i = 0, temp:size() - 1 do
        local player = temp:get(i)
        local plId = player:getOnlineID()
        self.playersInMatch[plId] = plId
    end

    -- Start timer and the event handling zombie spawning
    Countdown.Setup(PZ_EFT_CONFIG.MatchSettings.roundTime, function()
        debugPrint("Ending the round!")
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
        sendServerCommand(player, "PZEFT-State", "CommitDieIfInRaid", {})
    end
end

--- Extract the player and return to safehouse
---@param playerObj IsoPlayer
function MatchHandler:extractPlayer(playerObj)
    SafehouseInstanceManager.sendPlayerToSafehouse(playerObj)
    self:removePlayerFromMatchList(playerObj:getOnlineID())
end

---comment
---@param playerId number
function MatchHandler:removePlayerFromMatchList(playerId)
    self.playersInMatch[playerId] = nil
end

--- Stop the match and teleport back everyone
function MatchHandler:stopMatch()
    SafehouseInstanceManager.sendPlayersToSafehouse()
    PvpInstanceManager.getNextInstance()
    MatchHandler.instance = nil
end

---Run it every once, depending on the Config, spawns zombies for each player
---@param loops number amount of time that this function has been called by Countdown
function MatchHandler.HandleZombieSpawns(loops)
    if MatchHandler.instance == nil then return end
    for k, plId in pairs(MatchHandler.instance.playersInMatch) do
        if plId ~= nil then
            local player = getPlayerByOnlineID(plId)
            if player ~= nil then
                local x = player:getX()
                local y = player:getY()

                -- We can't go overboard with addedX or addedY
                local randomX = ZombRand(20, 60)
                local randomY = ZombRand(20, 60)

                -- Flip sign for X
                if ZombRand(0,100) > 50 then
                    randomX = 0 - randomX
                end

                -- Flip sign for Y
                if ZombRand(0,100) > 50 then
                    randomY = 0 - randomY
                end


                -- TODO Amount of zombies should scale based on players amount too, to prevent from killing the server
                local zombiesAmount = loops  --math.floor(loops/2)
                debugPrint("spawning " .. zombiesAmount .. " near " .. player:getUsername())

                local sq = getSquare(x + randomX, y + randomY, 0)

                -- TODO Check if square is ok. If it's water or too near a player skip it
                addZombiesInOutfit(x + randomX, y + randomY, 0, zombiesAmount, "", 50, false, false, false, false, 1)
                addSound(player, math.floor(x), math.floor(y), 0, 300, 100)
            else
                debugPrint("player was nil")
            end
        else
            debugPrint("plid was nil")
        end
    end
end

--------------------------------------------------
--- Get the instance of MatchHandler
---@return MatchHandler
function MatchHandler.GetHandler()
    return MatchHandler.instance
end

return MatchHandler
