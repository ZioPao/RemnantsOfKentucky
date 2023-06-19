local BaseTimer = require("TimeLogic/BaseTimer")
local TimerHandler = {}
local os_time = os.time


function TimerHandler:new()
    local o = BaseTimer:new()
    setmetatable(o, self)
    self.__index = self

    return o
end


---Run a certain function every amount of time
---@param funcToRun function
---@param delay number
function TimerHandler:setFuncToRun(funcToRun, delay)

    -- TODO we should pass the current time to the function
    self.funcToRun = funcToRun


    self.delayToRunFunc = delay

    self.delayTimeToRunFunc = delay + os_time()     -- TODO Delay is in seconds for now
    self.timeSinceLastRunFunc = 0

end

function TimerHandler:initialise()
    Events.OnTick.Add(self.update)
end

function TimerHandler:update()
    BaseTimer.update(self)

    -- Handle func to be run every amount of time
    if self.funcToRun then
        if self.timeSinceLastRunFunc >= self.delayTimeToRunFunc then
            self.funcToRun(self.timeInSeconds)

            self.timeSinceLastRunFunc = os_time()
            self.delayTimeToRunFunc = os_time() + self.delayToRunFunc
        end
    end

end


function TimerHandler:syncWithClients()
    -- TODO we should check if our timer is synced with the clients to prevent issues
end


function TimerHandler:stop()
    Events.OnTick.Remove(self.update)
end



-- TODO We can use getDate from the server directly to handle the timer.
-- TODO Check out how lua_timers handle this kind of stuff



return TimerHandler