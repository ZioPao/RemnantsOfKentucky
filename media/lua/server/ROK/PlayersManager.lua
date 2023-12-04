---TODO Handle everything player related


local MODULE = EFT_MODULES.Common

local PlayersCommands = {}

---comment
---@param args {playerID : number}
function PlayersCommands.RelayStarterKit(_, args)
    local playerToRelay = getPlayerByOnlineID(args.playerID)
    debugPrint("Relaying starter kit to " .. playerToRelay:getUsername())
    sendServerCommand(playerToRelay, EFT_MODULES.Common, "ReceiveStarterKit", {})
end


local OnPlayersCommands = function(module, command, playerObj, args)
    if module == MODULE and PlayersCommands[command] then
        -- debugPrint("Client Command - " .. MODULE .. "." .. command)
        PlayersCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnPlayersCommands)