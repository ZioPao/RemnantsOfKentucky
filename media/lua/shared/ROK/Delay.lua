local os_time = os.time
local Delay = {}
Delay.instances = {}

---@param delay number
---@param func function
---@param name string?
function Delay:set(delay, func, name)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.eTime = os_time() + delay
    o.func = func
    if not name then name = "" end
    o.name = name
    --o.args = args

    debugPrint("Added function to delay. Delay=" .. tostring(delay) .. ", Func=" .. tostring(func))

    table.insert(Delay.instances, o)
end

function Delay.Initialize()
    debugPrint("Setting up Delay Handler")
    Events.OnTickEvenPaused.Remove(Delay.Handle)
    Events.OnTickEvenPaused.Add(Delay.Handle)
end

function Delay.Handle()
    local cTime = os_time()

    for i = 1, #Delay.instances do
        local inst = Delay.instances[i]
        if inst then
            --debugPrint("Running delay:  " .. tostring(inst.name))

            if cTime > inst.eTime then
                debugPrint("Delay: started function, removing instance nr " .. tostring(i))
                inst.func()
                table.remove(Delay.instances, i)
            end
        end
    end
end

if isServer() then
    Events.OnServerStarted.Add(Delay.Initialize)
elseif isClient() then
    Events.OnConnected.Add(Delay.Initialize)
end


return Delay
