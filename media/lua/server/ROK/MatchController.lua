if not isServer() then return end

require("ROK/DebugTools")
local Countdown = require("ROK/Countdown")
local PvpInstanceManager = require("ROK/PvpInstanceManager")
local SafehouseInstanceManager = require("ROK/SafehouseInstanceManager")

---------------------------------------------------

---@class MatchController
---@field pvpInstance pvpInstanceTable
---@field playersInMatch table<number,number>        Table of player ids
---@field amountPlayersInMatch number
---@field zombieSpawnMultiplier number
local MatchController = {}

---Creates new MatchController
---@return MatchController
function MatchController:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.pvpInstance = PvpInstanceManager.GetNextInstance()
    o.playersInMatch = {}

    ---@type MatchController
    MatchController.instance = o

    return o
end

function MatchController:initialise()
    if self.instance == nil then
        debugPrint("PZ_EFT: No more instances found!")
        MatchController.instance = nil
        return
    end

    -- Teleport everyone in the match
    PvpInstanceManager.TeleportPlayersToInstance()

    -- Add them to the list to keep track of them
    local temp = getOnlinePlayers()
    for i = 0, temp:size() - 1 do
        local player = temp:get(i)
        local plId = player:getOnlineID()
        self.playersInMatch[plId] = plId
    end

    -- Recalculate the amount of players once at startup
    MatchController.UpdateAlivePlayers()

    -- Default value for the zombie multiplier
    self:setZombieSpawnMultiplier(PZ_EFT_CONFIG.MatchSettings.zombieSpawnMultiplier)
end

---Wait 5 seconds before starting the match
function MatchController:waitForStart()
    debugPrint("Start wait")
    Countdown.Setup(PZ_EFT_CONFIG.MatchSettings.loadWaitTime, function () self:start() end, false)
    sendServerCommand(EFT_MODULES.UI, "OpenLoadingScreen", {})
end

---Setup teleporting players to their spawn points
function MatchController:start()
    debugPrint("Starting match!")


    -- Start timer and the event handling zombie spawning
    Countdown.Setup(PZ_EFT_CONFIG.MatchSettings.roundTime, function()
        debugPrint("Overtime!")
        self:startOvertime()
    end, true)

    -- Setup Zombie handling
    Countdown.AddIntervalFunc(PZ_EFT_CONFIG.MatchSettings.zombieIncreaseTime, MatchController.HandleZombieSpawns)

    -- Setup checking alive players to stop the match and such things
    Countdown.AddIntervalFunc(PZ_EFT_CONFIG.MatchSettings.checkAlivePlayersTime, MatchController.UpdateAlivePlayers)

    sendServerCommand(EFT_MODULES.UI, "CloseLoadingScreen", {})

end

function MatchController:startOvertime()
    Countdown.Setup(PZ_EFT_CONFIG.MatchSettings.roundOvertime, function()
        debugPrint("End match")
        MatchController:killAlivePlayers()
        self:stopMatch()
    end, true, "Overtime")
end

--- Kill players that are still in the pvp instance and didn't manage to escape in time
function MatchController:killAlivePlayers()
    for k, plID in pairs(self.playersInMatch) do
        if plID ~= nil then
            local pl = getPlayerByOnlineID(plID)
            sendServerCommand(pl, EFT_MODULES.State, "CommitDieIfInRaid", {})

        end
    end
end

--- Extract the player and return to safehouse
---@param playerObj IsoPlayer
function MatchController:extractPlayer(playerObj)
    SafehouseInstanceManager.SendPlayerToSafehouse(playerObj)
    self:removePlayerFromMatchList(playerObj:getOnlineID())
end

---@param playerId number
function MatchController:removePlayerFromMatchList(playerId)
    self.playersInMatch[playerId] = nil
end

--- Stop the match and teleport back everyone
function MatchController:stopMatch()
    Countdown.Stop()
    SafehouseInstanceManager.SendAllPlayersToSafehouses()
    MatchController.instance = nil
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

--* Events/Checks

---Run it every once, depending on the Config, spawns zombies for each player
---@param loops number amount of time that this function has been called by Countdown
function MatchController.HandleZombieSpawns(loops)
    local instance = MatchController.GetHandler()
    if instance == nil then return end

    local randomPlayers = {}

    -- Spawn Zombies
    for k, plId in pairs(instance.playersInMatch) do
        if plId ~= nil then
            local player = getPlayerByOnlineID(plId)
            if player ~= nil then
                local x = player:getX()
                local y = player:getY()

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
                local zombiesAmount = math.ceil((PZ_EFT_CONFIG.MatchSettings.zombiesAmountBase * loops * instance:getZombieSpawnMultiplier())/instance:getAmountAlivePlayers())
                debugPrint("spawning " .. zombiesAmount .. " near " .. player:getUsername())
                addZombiesInOutfit(sq:getX(), sq:getY(), 0, zombiesAmount, "", 50, false, false, false, false, 1)

                -- Get random players to send audio to
                if ZombRand(0, 100) > PZ_EFT_CONFIG.MatchSettings.chanceRandomSoundOnZombieSpawn then
                    table.insert(randomPlayers, {player = player, x = x, y = y})
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
        for i=1, #randomPlayers do
            ---@type {player : IsoPlayer, x : number, y : number}
            local playerTab = randomPlayers[i]
            debugPrint("Sending sound near player: " .. playerTab.player:getUsername())
            addSound(playerTab.player, math.floor(playerTab.x), math.floor(playerTab.y), 0, 300, 100)
        end

        Events.OnTick.Remove(WaitAndSendSound)
    end
    Events.OnTick.Add(WaitAndSendSound)
end

---Checks if there are players still alive in a match. When it gets to 0, stop the match
function MatchController.UpdateAlivePlayers()
    --debugPrint("checking alive players")
    local instance = MatchController.GetHandler()
    if instance == nil then return end
    --debugPrint("Instance available, checking now players")
    --debugPrint(MatchController.GetAmountAlivePlayers())

    local counter = 0
    for k, v in pairs(instance.playersInMatch) do

        if v then
            local testPl = getPlayerByOnlineID(v)
            -- ping player
            if testPl == nil then
                instance:removePlayerFromMatchList(v)
            else
                counter = counter + 1
            end
        end

    end

    instance.amountPlayersInMatch = counter

    if instance.amountPlayersInMatch == 0 then
        debugPrint("no alive players in match, stopping it")
        MatchController.instance:stopMatch()
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

---@param playerObj IsoPlayer
---@param args {stopTime : number}
function MatchCommands.StartCountdown(playerObj, args)
    local function StartMatch()
        debugPrint("Initialize match")
        local handler = MatchController:new()
        handler:initialise()
        handler:waitForStart()

        -- Closes automatically the admin panel\switch it to the during match one
        sendServerCommand(playerObj, EFT_MODULES.UI, 'SwitchMatchAdminUI', {startingState='BEFORE'})
    end

    -- TODO Can't load getText from here for some reason. Workaround
    local matchStartingText = "The match is starting"
    Countdown.Setup(args.stopTime, StartMatch, true, matchStartingText)
end

function MatchCommands.StopCountdown()
    Countdown.Stop()
end

---@param playerObj IsoPlayer
---@param args {stopTime : number}
function MatchCommands.StartMatchEndCountdown(playerObj, args)

    local function StopMatch()
        local handler = MatchController.GetHandler()
        if handler then handler:stopMatch() end

        sendServerCommand(playerObj, EFT_MODULES.UI, 'SwitchMatchAdminUI', {startingState='DURING'})
    end

    local text = "The match has ended"
    Countdown.Setup(args.stopTime, StopMatch, true, text)
end

---@param args {val : number}
function MatchCommands.SetZombieSpawnMultiplier(_, args)
    local instance = MatchController.GetHandler()
    if instance == nil then return end

    instance:setZombieSpawnMultiplier(args.val)
end

function MatchCommands.SendZombieSpawnMultiplier(playerObj)
    local instance = MatchController.GetHandler()
    if instance == nil then return end
    local spawnZombieMultiplier = instance:getZombieSpawnMultiplier()
    sendServerCommand(playerObj, EFT_MODULES.Match, "ReceiveCurrentZombieSpawnMultiplier", {spawnZombieMultiplier = spawnZombieMultiplier})

end

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
    sendServerCommand(playerObj, EFT_MODULES.State, "SetClientStateIsInRaid", {value = false})
end

---@param playerObj IsoPlayer
function MatchCommands.SendAlivePlayersAmount(playerObj)
    local instance = MatchController.GetHandler()

    if instance == nil then return end
    local counter = instance:getAmountAlivePlayers()
    --debugPrint("Alive players in match: " .. tostring(counter))
    sendServerCommand(playerObj, EFT_MODULES.UI, "ReceiveAlivePlayersAmount", {amount = counter})

end
---------------------------------
local OnMatchCommand = function(module, command, playerObj, args)
    if module == MODULE and MatchCommands[command] then
        --debugPrint("Client Command - " .. MODULE .. "." .. command)
        MatchCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnMatchCommand)



return MatchController
