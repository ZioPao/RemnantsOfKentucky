-- This is gonna be the main class which we're gonna derive every time related class from--
-- We'll do it on clients since we're using os.time() anyway, less stuffe that needs to run constantly on the server

local BaseTimer = {}
local os_time = os.time


function BaseTimer:new()
    local o ={}
    setmetatable(o, self)
    self.__index = self


    -- Let's init stuff here just to know what we're gonna use later
    o.startTime = 0
    o.currentTime = 0
    return o
end

function BaseTimer:initialise()
    print("Starting timer")
    Events.OnTick.Add(self.updateCurrentTime)
end


--* Getters
function BaseTimer:getStartTime()
    return self.startTime
end

function BaseTimer:getCurrentTime()
    return self.currentTime
end


--* Loop logic
function BaseTimer:updateCurrentTime()
    self.currentTime = os_time()

    -- TODO Every minute we'll send an ack to be sure that we're still synced with the clients?
end





---------------------------
return BaseTimer










