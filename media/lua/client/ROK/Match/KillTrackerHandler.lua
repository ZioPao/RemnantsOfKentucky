---@alias KillTrackerData table<int, KilLTrack>

---@class KillTrackerHandler
---@field data KillTrackerData
local KillTrackerHandler = {}
KillTrackerHandler.data = {}

function KillTrackerHandler.Init()
    --  Reset it
    KillTrackerHandler.data = {}
end
Events.PZEFT_OnMatchStart.Add(KillTrackerHandler.Init)

function KillTrackerHandler.GetData()
    return KillTrackerHandler.data
end

---@param victimUsername string
---@param time number
function KillTrackerHandler.AddKill(victimUsername, time)
    ---@type KilLTrack
    local tempTable = {
        victimUsername = victimUsername,
        timestamp = time
    }
    table.insert(KillTrackerHandler.data, tempTable)
end


return KillTrackerHandler