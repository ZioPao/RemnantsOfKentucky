local SafehouseInstanceManager = require("ROK/SafehouseInstanceManager")
local ServerBankManager = require("ROK/Economy/ServerBankManager")

--TODO Handle everything player related


local MODULE = EFT_MODULES.Common

local PlayersCommands = {}

---comment
---@param args {playerID : number}
function PlayersCommands.RelayStarterKit(_, args)
    local playerToRelay = getPlayerByOnlineID(args.playerID)
    debugPrint("Relaying starter kit to " .. playerToRelay:getUsername())
    sendServerCommand(playerToRelay, EFT_MODULES.Common, "ReceiveStarterKit", {})
end

function PlayersCommands.ResetPlayer(_, args)
    local playerToWipe = getPlayerByOnlineID(args.playerID)

    -- TODO Safehouse Handling
    SafehouseInstanceManager.ResetPlayerSafehouse(playerToWipe)

    -- TODO Bank Handling
    ServerBankManager.ResetBankAccount(playerToWipe:getUsername())

    -- TODO Inventory handling


end
local OnPlayersCommands = function(module, command, playerObj, args)
    if module == MODULE and PlayersCommands[command] then
        -- debugPrint("Client Command - " .. MODULE .. "." .. command)
        PlayersCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnPlayersCommands)