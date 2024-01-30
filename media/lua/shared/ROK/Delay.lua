local os_time = os.time
local Delay = {}
Delay.instances = {}

function Delay:set(delay, func)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.eTime = os_time() + delay
    o.func = func
    --o.args = args

    debugPrint("Added function to delay. Delay="..tostring(delay) .. ", Func=" ..tostring(func))

    table.insert(Delay.instances, o)
end

function Delay.Initialize()
    Events.OnTick.Remove(Delay.Handle)
    Events.OnTick.Add(Delay.Handle)
end

function Delay.Handle()
    local cTime = os_time()

    for i=1, #Delay.instances do
        local inst = Delay.instances[i]
        if inst and cTime > inst.eTime then
            debugPrint("Delay: started function, removing instance nr " .. tostring(i))
            inst.func()
            table.remove(Delay.instances, i)
        end
    end
end

return Delay

