local ClientState = require("ROK/ClientState")
-----------------

local MatchCommands = {}
local MODULE = EFT_MODULES.Match


---@param coords coords
function MatchCommands.TeleportToInstance(coords)
    local ClientCommon = require("ROK/ClientCommon")
    ClientCommon.Teleport(coords)
    ClientState.SetIsInRaid(true)
end

---@param args {victimUsername : string}
function MatchCommands.AddKill(args)
    local KillTrackerHandler = require("ROK/Match/KillTrackerHandler")
    KillTrackerHandler.AddKill(args.victimUsername, ClientState.GetCurrentTime())
end

local function OnMatchCommands(module, command, args)
    if (module == MODULE or module == MODULE) and MatchCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        MatchCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnMatchCommands)
