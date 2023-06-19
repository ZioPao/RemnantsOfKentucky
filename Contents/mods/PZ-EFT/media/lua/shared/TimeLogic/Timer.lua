local BaseTimer = require("TimeLogic/BaseTimer")
local TimerHandler = {}


function TimerHandler:new()
    local o = BaseTimer:new()
    setmetatable(o, self)
    self.__index = self

    return o
end


---Run a certain function every 5 minutes
---@param func function
function TimerHandler:runFuncFiveMinutes(func)

    -- TODO we should pass the current time to the function
    
    --func(self.currentTime)
end

-- TODO We can use getDate from the server directly to handle the timer.
-- TODO Check out how lua_timers handle this kind of stuff



return TimerHandler