if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then return end

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
  local playersArray = getOnlinePlayers()
  for i=0, playersArray:size() do
      -- Fetch spawn point and delete it
      local coords = PvpInstanceManager.popRandomSpawnPoint()

      if coords then
        local pl = playersArray:get(i)
        TeleportManager.Teleport(pl, coords.x, coords.y, coords.z)        
      end
  end

  --* Start timer and the event handling zombie spawning
  self.timer = TimerHandler:new()
  self.timer:setFuncToRun(self.handleZombieSpawns, 5)       -- will be run every 5 minnutes
  self.timer:initialise()
end

--- Kill players that are still in the pvp instance and didn't manage to escape in time
function MatchHandler:killAlivePlayers()
end

--- Extract the player and return to safehouse
---@param playerUsername string
function MatchHandler:extractPlayer(playerUsername)
    local safehouseKey = SafehouseInstanceManager.getPlayerSafehouseKey(playerUsername)
    local safehouseInstance = SafehouseInstanceManager.getSafehouseInstanceByKey(safehouseKey)
    local player = getPlayerByUserName(playerUsername)
    TeleportManager.Teleport(player, safehouseInstance.x, safehouseInstance.y, safehouseInstance.z)
end

function MatchHandler:stopMatch()

    -- Teleport back everyone
    local playersArray = getOnlinePlayers()
    for i=0, playersArray:size() do
        local pl = playersArray:get(i)
        local playerUsername = pl:getUsername()
        local safehouseKey = SafehouseInstanceManager.getPlayerSafehouseKey(playerUsername)
        local safehouseInstance = SafehouseInstanceManager.getSafehouseInstanceByKey(safehouseKey)
        TeleportManager.Teleport(pl, safehouseInstance.x, safehouseInstance.y, safehouseInstance.z)
    end
end



function MatchHandler:handleZombieSpawns(currentTime)
    -- TODO We need to manage the zombie spawns depending on the time.
end


--*********************-

function MatchHandler.GetHandler()
    return MatchHandler.currenthandler
end

return MatchHandler