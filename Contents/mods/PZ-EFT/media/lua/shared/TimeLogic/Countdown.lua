local BaseTimer = require("TimeLogic/BaseTimer")
local CountdownHandler = {}


function CountdownHandler:new()
    local o = BaseTimer:new()
    setmetatable(o, self)
    self.__index = self

    return o
end

---Run a function when the countdown is over
---@param func function
function CountdownHandler:onEndRun(func)
    -- ...
end

return CountdownHandler