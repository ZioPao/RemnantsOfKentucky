local SafehouseInstanceManager = require("ROK/SafehouseInstanceManager")
local ServerBankManager = require("ROK/Economy/ServerBankManager")


-- TODO System to reset player who alt + f4 (or crashes I guess?)

local PlayersManager = {}

---@private
---@param username string
---@param attrs {isMIA : boolean}
function PlayersManager.SetData(username, attrs)
    local cData = ServerData.Players.GetPlayersData()

    cData[username] = {
        isMIA = attrs.isMIA or cData[username].isMIA or false
    }

    ServerData.Players.SetPlayersData(cData)

end

---@param username string
function PlayersManager.MarkPlayerAsMIA(username)
    PlayersManager.SetData(username, {isMIA = true})
end




--Events.PZEFT_ServerModDataReady.Add(ServerShopManager.LoadShopPrices)


----------------------------------------------------------------
local MODULE = EFT_MODULES.Player
local PlayersCommands = {}

---@param args {playerID : number}
function PlayersCommands.RelayStarterKit(_, args)
    local playerToRelay = getPlayerByOnlineID(args.playerID)
    debugPrint("Relaying starter kit to " .. playerToRelay:getUsername())
    sendServerCommand(playerToRelay, EFT_MODULES.Safehouse, "ReceiveStarterKit", {})
end

---@param playerObj IsoPlayer
---@param args any
function PlayersCommands.CheckPlayer(playerObj, args)
    local username = playerObj:getUsername()
    PlayersManager.SetData(username, {})
    local cData = ServerData.Players.GetPlayersData()


    -- Missing in action check
    local isMIA = cData[username].isMIA

    if isMIA then
        debugPrint("Player was set as Missing in Action, doing something that he won't forger!")

    end


end




-- TODO NOT IMPLEMENTED!
function PlayersCommands.ResetPlayer(_, args)
    local playerToWipe = getPlayerByOnlineID(args.playerID)

    -- TODO Safehouse Handling
    SafehouseInstanceManager.ResetPlayerSafehouse(playerToWipe)

    -- TODO Bank Handling
    ServerBankManager.ResetBankAccount(playerToWipe:getUsername())

    -- TODO Inventory handling


end


local function OnPlayersCommands(module, command, playerObj, args)
    if module == MODULE and PlayersCommands[command] then
        -- debugPrint("Client Command - " .. MODULE .. "." .. command)
        PlayersCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnPlayersCommands)



return PlayersManager