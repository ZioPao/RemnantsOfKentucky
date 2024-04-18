if not isServer() then return end

require("ROK/DebugTools")
local Countdown = require("ROK/Countdown")
local PvpInstanceManager = require("ROK/PvpInstanceManager")
local SafehouseInstanceManager = require("ROK/SafehouseInstanceManager")
local PlayersManager = require("ROK/PlayersManager")

---------------------------------------------------

local MATCH_STARTING_STR = "The match is starting"


----------------

---@class MatchController
---@field pvpInstance pvpInstanceTable
---@field playersInMatch table<number,{playerId : number, username : string}>        Table of player ids and usernames
---@field amountPlayersInMatch number
---@field zombieSpawnMultiplier number
local MatchController = {

    -- Static attributes
    isAutomaticStart = false
}

---Creates new MatchController
---@return MatchController
function MatchController:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.pvpInstance = PvpInstanceManager.GetNextInstance()
    o.playersInMatch = {}
    o.amountPlayersInMatch = 0

    ---@type MatchController
    MatchController.instance = o

    return o
end

function MatchController:initialise()
    if self.pvpInstance == nil then
        debugPrint("PZ_EFT: No more PVP instances found!")
        MatchController.instance = nil
        return
    end

    -- Opens the loading screen for everyone and add boom sound
    sendServerCommand(EFT_MODULES.UI, "OpenLoadingScreen", { sound = "BoomSound" }) -- Boom sound by Garuda1982

    -- Init players in match


    local areSpawnpointsAllUsed = false
    local playersArray = getOnlinePlayers()
    for i = 0, playersArray:size() - 1 do
        ---@type IsoPlayer
        local player = playersArray:get(i)
        local plUsername = player:getUsername()

        if player:isAlive() then
            debugPrint("Adding " .. plUsername .. " to match")

            -- Add them to the list to keep track of them
            local plId = player:getOnlineID()
            if plId then

                local spawnPoint = PvpInstanceManager.PopRandomSpawnPoint()
                if spawnPoint then
                    debugPrint("Teleporting " .. plUsername .. " to " .. spawnPoint.name)
                    sendServerCommand(player, EFT_MODULES.Match, "TeleportToInstance", spawnPoint)
                    self:addPlayerToMatchList(plId, plUsername)
                else
                    areSpawnpointsAllUsed = true
                    debugPrint("No more spawnpoints! Can't teleport player!")
                    sendServerCommand(player, EFT_MODULES.State, "ForceQuit", {})
                end
            end
        end
    end

    if areSpawnpointsAllUsed then
        --sendServerCommand()
        -- TODO Notify admin that spawnpoints are not enough for this amount of players
    end




    -- Default value for the zombie multiplier
    self:setZombieSpawnMultiplier(PZ_EFT_CONFIG.Server.Match.zombieSpawnMultiplier)
end

---Setup teleporting players to their spawn points
function MatchController:startMatch()
    debugPrint("Starting match!")

    -- Delay to let the clients load the map in its entirity

    local Delay = require("ROK/Delay")


    -- TODO Make delay dynamic based on player teleportation status from the server side...?
    Delay:set(2, function()
        -- Start timer and the event handling zombie spawning
        Countdown.Setup(SandboxVars.RemnantsOfKentucky.RoundTime, function()
            debugPrint("Overtime!")
            self:startOvertime()
        end, true)

        -- Setup Zombie handling
        Countdown.AddIntervalFunc(PZ_EFT_CONFIG.Server.Match.zombieIncreaseTime, MatchController.HandleZombieSpawns)

        -- Setup checking alive players to stop the match and such things
        Countdown.AddIntervalFunc(PZ_EFT_CONFIG.Server.Match.checkAlivePlayersTime, MatchController.CheckAlivePlayers)

        sendServerCommand(EFT_MODULES.UI, "CloseLoadingScreen", {})

        triggerEvent("PZEFT_OnMatchStart")
    end)
end

function MatchController:stopMatch()
    Countdown.Stop()
    MatchController.instance = nil
    sendServerCommand(EFT_MODULES.UI, 'SwitchMatchAdminUI', { startingState = 'DURING' })

    triggerEvent("PZEFT_OnMatchEnd") -- OnMatchEnd on the server
end

--- Stop the match and teleport back everyone. Triggered manually by an admin
function MatchController:manualStopMatch()
    self:stopMatch()
    SafehouseInstanceManager.SendAllPlayersToSafehouses()
end

--- Extract the player and return to safehouse
---@param playerObj IsoPlayer
function MatchController:extractPlayer(playerObj)
    SafehouseInstanceManager.SendPlayerToSafehouse(playerObj)
    self:removePlayerFromMatchList(playerObj:getOnlineID())
    sendServerCommand(playerObj, EFT_MODULES.UI, "OpenRecapPanel", {})
end

--* Overtime

function MatchController:startOvertime()
    Countdown.Setup(SandboxVars.RemnantsOfKentucky.RoundOvertime, function()
        self:stopOvertime()
    end, true, "Overtime")
end

function MatchController:stopOvertime()
    self:stopMatch()
    self:killAlivePlayers()
end

--- Kill players that are still in the pvp instance and didn't manage to escape in time
function MatchController:killAlivePlayers()
    debugPrint("Killing remaining players in match")
    for k, tab in pairs(self.playersInMatch) do
        if tab ~= nil then
            local plID = tab.playerId
            local pl = getPlayerByOnlineID(plID)
            sendServerCommand(pl, EFT_MODULES.State, "CommitDieIfInRaid", {})
        end
    end
end

--* Getter/Setters

---@param val number
function MatchController:setZombieSpawnMultiplier(val)
    self.zombieSpawnMultiplier = val
end

function MatchController:getZombieSpawnMultiplier()
    return self.zombieSpawnMultiplier
end

function MatchController:getAmountAlivePlayers()
    return self.amountPlayersInMatch
end

--* Various Events

---Run it every once, depending on the Config, spawns zombies for each player
---@param loops number amount of time that this function has been called by Countdown
function MatchController.HandleZombieSpawns(loops)
    -- TODO Implement check to prevent zombies from spawning near other players
    -- ---@param nearbyPlayers table<integer,{x : number, y : number}>
    -- ---@param x number
    -- ---@param y number
    -- local function IsSpawnNearPlayer(nearbyPlayers, x,y)
    --     for i=1, #nearbyPlayers do

    --     end
    -- end


    local instance = MatchController.GetHandler()
    if instance == nil then return end

    local randomPlayers = {}

    -- Spawn Zombies
    for k, v in pairs(instance.playersInMatch) do
        if v ~= nil then
            local plId = v.playerId
            local player = getPlayerByOnlineID(plId)
            if player ~= nil then
                local x = player:getX()
                local y = player:getY()


                -- TODO Finish this thing, which is Heavy heavy heavy
                -- map players position
                -- local nearPlayers = {}
                -- for k2, v2 in pairs(instance.playersInMatch) do
                --     if v ~= nil then
                --         local otherPlId = v.playerId
                --         local otherPlayer = getPlayerByOnlineID(otherPlId)
                --         local opX = otherPlayer:getX()
                --         local opY = otherPlayer:getY()

                --         local dist = IsoUtils.DistanceTo(x, y, opX, opY)

                --         if dist < 50 then
                --             table.insert(nearPlayers, { plId = otherPlId, x = opX, y = opY })
                --         end
                --     end
                -- end


                -- We can't go overboard with addedX or addedY
                local sq
                repeat
                    local randomX = ZombRand(20, 60) * (ZombRand(0, 100) > 50 and -1 or 1)
                    local randomY = ZombRand(20, 60) * (ZombRand(0, 100) > 50 and -1 or 1)
                    sq = getSquare(x + randomX, y + randomY, 0)
                    ---@diagnostic disable-next-line: param-type-mismatch
                until sq and not sq:getFloor():getSprite():getProperties():Is(IsoFlagType.water)

                -- Amount of zombies should scale based on players amount too, to prevent from killing the server
                -- The more players there are, the more zombies will spawn in total, but less per player
                -- (Base amount * loop) / players in match
                local zombiesAmount = math.ceil((PZ_EFT_CONFIG.Server.Match.zombiesAmountBase * loops * instance:getZombieSpawnMultiplier()) /
                    instance:getAmountAlivePlayers())
                debugPrint("spawning " .. zombiesAmount .. " near " .. player:getUsername())
                addZombiesInOutfit(sq:getX(), sq:getY(), 0, zombiesAmount, "", 50, false, false, false, false, 1)

                -- Get random players to send audio to
                if ZombRand(0, 100) > PZ_EFT_CONFIG.Server.Match.chanceRandomSoundOnZombieSpawn then
                    table.insert(randomPlayers, { player = player, x = x, y = y })
                end
            else
                debugPrint("player was nil")
            end
        else
            debugPrint("plid was nil")
        end
    end

    -- Handle sound
    -- We need to delay this a bit to be sure that it works correctly
    local os_time = os.time
    local eTime = os_time() + 2


    local function WaitAndSendSound()
        local cTime = os_time()
        if cTime < eTime then return end
        for i = 1, #randomPlayers do
            ---@type {player : IsoPlayer, x : number, y : number}
            local playerTab = randomPlayers[i]
            debugPrint("Sending sound near player: " .. playerTab.player:getUsername())
            addSound(playerTab.player, math.floor(playerTab.x), math.floor(playerTab.y), 0, 300, 100)
        end

        Events.OnTick.Remove(WaitAndSendSound)
    end
    Events.OnTick.Add(WaitAndSendSound)
end

---@param playerObj IsoPlayer
function MatchController.HandlePlayerDeath(playerObj)
    if playerObj:isZombie() then return end

    local killerObj = playerObj:getAttackedBy()
    ---@cast killerObj IsoPlayer

    if killerObj and killerObj ~= playerObj then
        -- Add to kill count, send it back to client
        sendServerCommand(killerObj, EFT_MODULES.Match, 'AddKill', { victimUsername = playerObj:getUsername() })
    end

    -- Removes player from the match, preventing them from despawning crap
    MatchController.GetHandler():removePlayerFromMatchList(playerObj:getOnlineID())
end

Events.OnCharacterDeath.Add(MatchController.HandlePlayerDeath)


--* Automatic Startup

-- Events.OnServerStarted.Add(function()
--     --     -- TODO Add event "WaitForFirstPlayer"
--     MatchController.isAutomaticStart = SandboxVars.RemnantsOfKentucky.IsAutomaticStartEnabled
-- end)

-- Events.OnConnected.Add(function()


-- end)

Events.OnDisconnect.Add(function()
    local onlinePlayers = getOnlinePlayers()
    if onlinePlayers == 0 then
        Countdown.Stop()
    end
end)


-- if MatchController.isAutomaticStart then

--     Events.PZEFT_OnMatchEnd.Add(MatchController.AutoStartMatch)
--     Events.PZEFT_ServerModDataReady.Add(MatchController.AutoStartMatch)
-- end



function MatchController.AutoStartMatch()
    debugPrint("AutoStartMatch function activated!")
    Countdown.Setup(SandboxVars.RemnantsOfKentucky.AutomaticStartCountdownTime, function()
        local handler = MatchController:new()
        handler:initialise()
        handler:startMatch()
    end, true, MATCH_STARTING_STR)
end

function MatchController.ToggleAutomaticStart()
    MatchController.isAutomaticStart = not MatchController.isAutomaticStart
    if MatchController.isAutomaticStart then
        -- Add event
        Events.PZEFT_OnMatchEnd.Remove(MatchController.AutoStartMatch)
        Events.PZEFT_OnMatchEnd.Add(MatchController.AutoStartMatch)

        -- Trigger start
        MatchController.AutoStartMatch()
    else
        -- Disable event
        Events.PZEFT_OnMatchEnd.Remove(MatchController.AutoStartMatch)

        -- Force stop the countdown
        Countdown.Stop()
    end
end

------------------------
--* Match List

--- Checks if a player is in the match list or not
---@param playerId number
---@return boolean
function MatchController:isPlayerInMatchList(playerId)
    if self.playersInMatch[playerId] then return true else return false end
end

---@param playerId number
---@param username string
function MatchController:addPlayerToMatchList(playerId, username)
    if self:isPlayerInMatchList(playerId) then
        debugPrint("Player " .. tostring(username) .. " is already in the match, won't re-add it")
        return
    end

    self.playersInMatch[playerId] = {
        playerId = playerId,
        username = username
    }
    self.amountPlayersInMatch = self.amountPlayersInMatch + 1
end

---@param playerId number
function MatchController:removePlayerFromMatchList(playerId)
    if self:isPlayerInMatchList(playerId) then
        debugPrint("Removing player with ID " .. tostring(playerId) .. " from match list")
        self.playersInMatch[playerId] = nil
        self.amountPlayersInMatch = self.amountPlayersInMatch - 1
    end
end

---Checks if there are players still alive in a match. When it gets to 0, stop the match
---We have to check it periodically to account for crashes
function MatchController.CheckAlivePlayers()
    --debugPrint("checking alive players")
    local instance = MatchController.GetHandler()
    if instance == nil then return end
    for k, v in pairs(instance.playersInMatch) do
        if v then
            local plId = v.playerId
            local plUsername = v.username
            local testPl = getPlayerByOnlineID(plId)
            -- ping player
            if testPl == nil then
                PlayersManager.MarkPlayerAsMIA(plUsername)
                instance:removePlayerFromMatchList(plId)
            elseif testPl and testPl:isDead() then
                instance:removePlayerFromMatchList(plId)
            end
        end
    end

    if instance.amountPlayersInMatch == 0 then
        debugPrint("no alive players in match, stopping it")
        MatchController.instance:stopMatch()
    end
end

--------------------------------------------------
--- Get the instance of MatchController
---@return MatchController
function MatchController.GetHandler()
    if MatchController.instance then
        return MatchController.instance
    else
        debugPrint("Match controller instance is nil")
        return nil
    end
end

---
function MatchController.CheckIsMatchRunning()
    local handler = MatchController.GetHandler()
    local isMatchRunning = handler ~= nil
    debugPrint("isMatchRunning = " .. tostring(isMatchRunning))
    return isMatchRunning
end
------------------------------------------------------------------------
--* COMMANDS FROM CLIENTS *--
------------------------------------------------------------------------

local MODULE = EFT_MODULES.Match
local MatchCommands = {}


function MatchCommands.SendExtractionTime(playerObj)
    local extTime = SandboxVars.RemnantsOfKentucky.ExtractionTime
    sendServerCommand(playerObj, EFT_MODULES.State, 'SetExtractionTime', { extractionTime = extTime })
end

---Client is asking if a match is running
---@param playerObj IsoPlayer
function MatchCommands.CheckIsRunningMatch(playerObj)
    debugPrint("Client asked if match is running")
    local isMatchRunning = MatchController.CheckIsMatchRunning()
    sendServerCommand(playerObj, EFT_MODULES.State, 'SetClientStateIsMatchRunning', { value = isMatchRunning })
end

---Client is asking if automatic matches are active
---@param playerObj IsoPlayer
function MatchCommands.CheckIsAutomaticStart(playerObj)
    debugPrint("Client asked if automatic start is enabled")
    sendServerCommand(playerObj, EFT_MODULES.State, 'SetClientStateIsAutomaticStart',
        { value = MatchController.isAutomaticStart })
end

---@param args {id : number}
function MatchCommands.KillZombies(_, args)
    local id = args.id
    local zombies = getCell():getZombieList()
    for i = 0, zombies:size() - 1 do
        local zombie = zombies:get(i)
        if instanceof(zombie, "IsoZombie") and zombie:getOnlineID() == id then
            debugPrint("Removing zombie with id=" .. tostring(id))
            zombie:removeFromWorld()
            zombie:removeFromSquare()
            return
        end
    end
end

function MatchCommands.ToggleAutomaticStart()
    MatchController.ToggleAutomaticStart()
end

---@param args {stopTime : number}
function MatchCommands.StartCountdown(_, args)
    local function StartMatch()
        debugPrint("Initialize match")
        local handler = MatchController:new()
        handler:initialise()
        handler:startMatch()

        -- Closes automatically the admin panel\switch it to the during match one
        sendServerCommand(EFT_MODULES.UI, 'SwitchMatchAdminUI', { startingState = 'BEFORE' })
    end

    Countdown.Setup(args.stopTime, StartMatch, true, MATCH_STARTING_STR)
end

function MatchCommands.StopCountdown()
    Countdown.Stop()
end

---@param playerObj IsoPlayer
---@param args {stopTime : number}
function MatchCommands.StartMatchEndCountdown(playerObj, args)
    local function StopMatch()
        local handler = MatchController.GetHandler()
        if handler then handler:manualStopMatch() end

        sendServerCommand(playerObj, EFT_MODULES.UI, 'SwitchMatchAdminUI', { startingState = 'DURING' })
    end

    local text = "The match has ended"
    Countdown.Setup(args.stopTime, StopMatch, true, text)
end

---@param args {val : number}
function MatchCommands.SetZombieSpawnMultiplier(_, args)
    local handler = MatchController.GetHandler()
    debugPrint("Setting zombie multiplier to " .. tostring(args.val))
    handler:setZombieSpawnMultiplier(args.val)
end

function MatchCommands.SendZombieSpawnMultiplier(playerObj)

    debugPrint("Player " .. playerObj:getUsername() .. " asked for Zombie Spawn Multiplayer")

    local spawnZombieMultiplier = PZ_EFT_CONFIG.Server.Match.zombieSpawnMultiplier
    sendServerCommand(playerObj, EFT_MODULES.UI, "ReceiveCurrentZombieSpawnMultiplier",
        { spawnZombieMultiplier = spawnZombieMultiplier })
end

---A client has sent an extraction request
---@param playerObj IsoPlayer player requesting extraction
function MatchCommands.RequestExtraction(playerObj)
    local handler = MatchController.GetHandler()
    debugPrint("Running extraction for player " .. playerObj:getUsername())
    handler:extractPlayer(playerObj)
end

---Removes a player from the current match
---@param playerObj IsoPlayer
function MatchCommands.RemovePlayer(playerObj)
    local handler = MatchController.GetHandler()
    handler:removePlayerFromMatchList(playerObj:getOnlineID())
    sendServerCommand(playerObj, EFT_MODULES.State, "SetClientStateIsInRaid", { value = false })
end

---@param playerObj IsoPlayer
function MatchCommands.SendAlivePlayersAmount(playerObj)
    local handler = MatchController.GetHandler()
    local counter = -1
    if handler then
        counter = handler:getAmountAlivePlayers()
    end
    --debugPrint("Alive players in match: " .. tostring(counter))
    sendServerCommand(playerObj, EFT_MODULES.UI, "ReceiveAlivePlayersAmount", { amount = counter })
end

---------------------------------
local function OnMatchCommand(module, command, playerObj, args)
    if module == MODULE and MatchCommands[command] then
        --debugPrint("Client Command - " .. MODULE .. "." .. command)
        MatchCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnMatchCommand)



return MatchController
