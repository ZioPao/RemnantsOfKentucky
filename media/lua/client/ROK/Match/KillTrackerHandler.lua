


-- TODO Receive confirmation from the server after successful kill
local MODULE = EFT_MODULES.KillTracker


local KillTrackerCommands = {}

function KillTrackerCommands.AddKill(args)

end

local function OnKillTrackerCommand(module, command, args)
    if (module == MODULE or module == MODULE) and KillTrackerCommands[command] then
        KillTrackerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnKillTrackerCommand)
