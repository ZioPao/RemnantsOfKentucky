local MatchCommands = {}
local MODULE = EFT_MODULES.Match


function MatchCommands.TeleportToInstance(coords)
    local ClientCommon = require("ROK/ClientCommon")
    local ClientState = require("ROK/ClientState")
    ClientCommon.Teleport(coords)
    ClientState.SetIsInRaid(true)
end



local function OnMatchCommands(module, command, args)
    if (module == MODULE or module == MODULE) and MatchCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        MatchCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnMatchCommands)
