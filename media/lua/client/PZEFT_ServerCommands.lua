require "PZEFT_debugtools"

local ServerCommands = {}

local MODULE = 'PZEFT'

ServerCommands.SeverModDataReady = function(playerObj)
    triggerEvent("PZEFT_ClientModDataReady")
end

local OnServerCommand = function(module, command, args)
    if module == MODULE and ServerCommands[command] then
        debugPrint("Server Command - " .. MODULE .. "." .. command)
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)