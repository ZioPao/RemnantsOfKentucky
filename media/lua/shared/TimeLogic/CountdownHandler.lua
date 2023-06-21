local BaseTimer = require("TimeLogic/BaseTimer")
local os_time = os.time
local CountdownHandler = {}

--- Set a countdown
---@param timeInSeconds number
---@param funcToRun function
---@return table
function CountdownHandler:new(timeInSeconds, funcToRun)
    local o = BaseTimer:new()
    setmetatable(o, self)
    self.__index = self

    o.endTime = os_time() + timeInSeconds    -- in seconds
    o.funcToRun = funcToRun
    return o
end

function CountdownHandler:initialise()
    BaseTimer.initialise(self)
    Events.OnTick.Add(self.update)
end

function CountdownHandler:update()
    BaseTimer.update(self)

    print(tostring(self.currentTime))
    if self.endTime <= self.currentTime then
        self.funcToRun()
        self:stop()
    end
end

function CountdownHandler:stop()
    BaseTimer.stop(self)
    Events.OnTick.Remove(self.update)
end

return CountdownHandler