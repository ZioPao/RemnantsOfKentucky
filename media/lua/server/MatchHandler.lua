local MatchHandler = {}

local TimerHandler = require("TimeLogic/Timer")
local CountdownHandler = require("TimeLogic/Countdown")

function MatchHandler:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.instance = PvpInstanceManager.getNextInstance()

    return o
end

function MatchHandler:initialise()
    if self.instance == nil then
        print("PZ_EFT: No more instances found!")
        return false
    end

    --* Start a countdown until the start of the game
    self.countdown = CountdownHandler:new(30, self.start)       -- 30 seconds
    self.countdown:initialise()

    return true
end


function MatchHandler:start()
  -- * Setup teleporting players to their spawn points
  local playersArray = getOnlinePlayers()
  for i=0, playersArray:size() do
      -- Fetch spawn point and delete it
      local coords = PvpInstanceManager.popRandomSpawnPoint()

      if coords then
        local pl = playersArray:get(i)
        PZEFT_UTILS.TeleportPlayer(pl, coords.x, coords.y, coords.z)
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
---@param playerUsername number
function MatchHandler:extractPlayer(playerUsername)
    local safehouseKey = SafehouseInstanceManager.getPlayerSafehouseKey(playerUsername)
    local safehouseInstance = SafehouseInstanceManager.getSafehouseInstanceByKey(safehouseKey)
    local player = getPlayerByUserName(playerUsername)
    PZEFT_UTILS.TeleportPlayer(player, safehouseInstance.x, safehouseInstance.y, safehouseInstance.z)
end

function MatchHandler:handleZombieSpawns(currentTime)
    -- TODO We need to manage the zombie spawns depending on the time.
end

return MatchHandler