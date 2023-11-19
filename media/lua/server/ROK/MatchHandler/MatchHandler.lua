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



    -- TODO Start loop until we can actually trigger a correct spawn

    



    debugPrint(loops)     
    debugPrint("Running HandleZombie!")

    local matchInstance = MatchHandler.GetHandler()
    
    -- Calculate center of area between players


    -- Validation cycle
    -- for i = 1, #MatchHandler.players do
    --     local player = MatchHandler.players[i]

    --     -- TODO Check if player is valid. We should have a reference to its clientState to work
    --     table.insert(availablePlayers, player)
    -- end


    --table.insert(availablePlayers, getPlayerByOnlineID(0))


    local spawnPoint
    local isValid = false
    local isActive = false

    local pvpInstance = PvpInstanceManager.getCurrentInstance()
    
    for i=1, #pvpInstance.spawnPoints do
        spawnPoint = pvpInstance.spawnPoints[i]

        local onlinePlayers = getOnlinePlayers()

        for y=0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(y)
            if IsoUtils.DistanceTo(spawnPoint.x, spawnPoint.y, player:getX(), player:getY()) > 50 then
                isValid = true
            end

            if not isActive then
                if IsoUtils.DistanceTo(spawnPoint.x, spawnPoint.y, player:getX(), player:getY()) < 200 then
                    debugPrint("player close enough to this current spawnpoint!")
                    isActive = true
                end
            end
            -- todo at least one player should be "close enough" to the chunk
        end

        if isValid and isActive then
            debugPrint("Found spawn point for zombies: x= " .. spawnPoint.x .. ", y=" .. spawnPoint.y)
            break
        else
            isActive = false
            spawnPoint = nil
        end
    end

    if spawnPoint ~= nil then
        debugPrint("Spawning " .. 100*loops .. " zombies")
        -- TODO Won't work, we need to check if the chunk is loaded and ready. An OnTick should loop through the prepared zombie spawns?
        addZombiesInOutfit(spawnPoint.x, spawnPoint.y, 0, 100 * loops, "", 50, false, false, false, false, 1)
    end



end

--------------------------------------------------
--- Get the instance of MatchHandler
---@return MatchHandler
function MatchHandler.GetHandler()
    return MatchHandler.instance
end

return MatchHandler
