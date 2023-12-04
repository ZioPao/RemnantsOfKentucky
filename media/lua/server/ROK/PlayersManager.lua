---TODO Handle everything player related


local MODULE = EFT_MODULES.Common

local PlayersCommands = {}

function PlayersCommands.RelayStarterKit(playerObj, args)
    sendServerCommand(playerObj, MODULE, "ReceiveStarterKit", {})
end


local OnPvpInstanceCommands = function(module, command, playerObj, args)
    if module == MODULE and PlayersCommands[command] then
        -- debugPrint("Client Command - " .. MODULE .. "." .. command)
        PlayersCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnPvpInstanceCommands)