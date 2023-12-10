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

    table.insert(Delay.instances, o)
end

function Delay.Initialize()
    Events.OnTick.Add(Delay.Handle)
end

function Delay.Handle()
    local cTime = os_time()

    for i=1, #Delay.instances do
        local inst = Delay.instances[i]
        if cTime > inst.eTime then
            inst.func()
            table.remove(Delay.instances, i)
        end
    end
end

return Delay

