---@alias KilLTrack {victimUsername : string, timestamp : any}
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


function KillTrackerHandler.AddKill(victimUsername, time)
    ---@type KilLTrack
    local tempTable = {
        victimUsername = victimUsername,
        timestamp = time
    }
    table.insert(KillTrackerHandler.data, tempTable)
end








-----------------------------------------


-- TODO Receive confirmation from the server after successful kill
local MODULE = EFT_MODULES.KillTracker


local KillTrackerCommands = {}

---@param args {victimUsername : string}
function KillTrackerCommands.AddKill(args)
    local cTime = os.time()
    KillTrackerHandler.AddKill(args.victimUsername, cTime)
end

local function OnKillTrackerCommand(module, command, args)
    if (module == MODULE or module == MODULE) and KillTrackerCommands[command] then
        KillTrackerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnKillTrackerCommand)



return KillTrackerHandler