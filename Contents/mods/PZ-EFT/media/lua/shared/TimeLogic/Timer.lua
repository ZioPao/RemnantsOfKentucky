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
---@param delay number delay in minutes
function TimerHandler:setFuncToRun(funcToRun, delay)

    self.funcToRun = funcToRun
    self.delayToRunFunc = delay * 60
    self.delayTimeToRunFunc = self.delayToRunFunc + os_time()
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

function TimerHandler:stop()
    Events.OnTick.Remove(self.update)
end



return TimerHandler