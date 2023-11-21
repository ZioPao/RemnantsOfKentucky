if not isServer() then return end

require("ROK/DebugTools")
require "ROK/TeleportManager"
local Countdown = require("ROK/Time/Countdown")
local PvpInstanceManager = require("ROK/PvpInstanceManager")

---------------------------------------------------

---@class MatchController
---@field pvpInstance pvpInstanceTable
---@field playersInMatch table<number,number>        Table of player ids
local MatchController = {}

---Creates new MatchController
---@return MatchController
function MatchController:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.pvpInstance = PvpInstanceManager.GetNextInstance()
    o.playersInMatch = {}

    MatchController.instance = o

    return o
end

function MatchController:initialise()
    if self.instance == nil then
        debugPrint("PZ_EFT: No more instances found!")
        MatchController.instance = nil
        return
    end

    self:start()
end

---Setup teleporting players to their spawn points
function MatchController:start()
    debugPrint("Starting match!")
    PvpInstanceManager.TeleportPlayersToInstance()  -- TODO this is kinda shaky, we should integrate it here in MatchController

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
    Countdown.AddIntervalFunc(PZ_EFT_CONFIG.MatchSettings.zombieIncreaseTime, MatchController.HandleZombieSpawns)

end

--- Kill players that are still in the pvp instance and didn't manage to escape in time
function MatchController:killAlivePlayers()
    local temp = getOnlinePlayers()
    for i = 0, temp:size() - 1 do
        local player = temp:get(i)
        sendServerCommand(player, "PZEFT-State", "CommitDieIfInRaid", {})
    end
end

--- Extract the player and return to safehouse
---@param playerObj IsoPlayer
function MatchController:extractPlayer(playerObj)
    SafehouseInstanceManager.SendPlayerToSafehouse(playerObj)
    self:removePlayerFromMatchList(playerObj:getOnlineID())
end

---comment
---@param playerId number
function MatchController:removePlayerFromMatchList(playerId)
    self.playersInMatch[playerId] = nil
end

--- Stop the match and teleport back everyone
function MatchController:stopMatch()
    SafehouseInstanceManager.SendPlayersToSafehouse()
    MatchController.instance = nil
end

---Run it every once, depending on the Config, spawns zombies for each player
---@param loops number amount of time that this function has been called by Countdown
function MatchController.HandleZombieSpawns(loops)
    if MatchController.instance == nil then return end
    for k, plId in pairs(MatchController.instance.playersInMatch) do
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
--- Get the instance of MatchController
---@return MatchController
function MatchController.GetHandler()
    return MatchController.instance
end


------------------------------------------------------------------------
--* COMMANDS FROM CLIENTS *--
------------------------------------------------------------------------

local MODULE = EFT_MODULES.Match
local MatchCommands = {}

---A client has sent an extraction request
---@param playerObj IsoPlayer player requesting extraction
function MatchCommands.RequestExtraction(playerObj)
    local instance = MatchController.GetHandler()
    if instance == nil then return end
    instance:extractPlayer(playerObj)
end

---Removes a player from the current match
---@param playerObj IsoPlayer
function MatchCommands.RemovePlayer(playerObj)
    local instance = MatchController.GetHandler()
    if instance == nil then return end
    instance:removePlayerFromMatchList(playerObj:getOnlineID())
end

---@param playerObj IsoPlayer
function MatchCommands.SendAlivePlayersAmount(playerObj)
    local instance = MatchController.GetHandler()

    if instance == nil then return end
    local counter = 0
    for k,v in pairs(instance.playersInMatch) do
        if v then
            counter = counter + 1
        end
    end
    debugPrint("Alive players in match: " .. tostring(counter))
    sendServerCommand(playerObj, EFT_MODULES.UI, "ReceiveAlivePlayersAmount", {amount = counter})

end
---------------------------------
local OnMatchCommand = function(module, command, playerObj, args)
    if module == MODULE and MatchCommands[command] then
        -- debugPrint("Client Command - " .. MODULE .. "." .. command)
        MatchCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnMatchCommand)



return MatchController
