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
    -- TODO When countdown is over, start the actual match
    self.countdown = CountdownHandler:new()
    self.countdown:initialise()
    self.countdown:onEndRun(self.start)

    return true
end


function MatchHandler:start()
  -- * Setup teleporting players to their spawn points
  local playersArray = getOnlinePlayers()
  for i=0, playersArray:size() do
      -- Fetch spawn point and delete it
      local id = PvpInstanceManager.FetchRandomSpawnPointIndex()
      local coords = instance.spawnPoints[id]
      PvpInstanceManager.DeleteSpawnPoint(id)

      local pl = playersArray:get(i)
      PZEFT_UTILS.TeleportPlayer(pl, coords.x, coords.y, coords.z)
  end

  --* Start timer
  self.timer = TimerHandler:new()
  self.timer:initialise()



  --* Start the event handling zombie spawning
  -- TODO This will depend on the timer.
  self.timer:runFuncFiveMinutes(self.handleZombieSpawns)


end

function MatchHandler:handleZombieSpawns(currentTime)
    -- TODO We need to manage the zombie spawns depending on the time.
end