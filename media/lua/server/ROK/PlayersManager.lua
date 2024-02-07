if not isServer() then return end

local SafehouseInstanceManager = require("ROK/SafehouseInstanceManager")
local ServerBankManager = require("ROK/Economy/ServerBankManager")


-- TODO System to reset player who alt + f4 (or crashes I guess?)

local PlayersManager = {}


function PlayersManager.GetOrCreateData(username)
    local cData = ServerData.Players.GetPlayersData()

    if cData[username] == nil then
        cData[username] = {
            isMIA = false
        }
        ServerData.Players.SetPlayersData(cData)
    end

    return cData[username]
end



---@private
---@param username string
---@param attrs {isMIA : boolean}
function PlayersManager.SetData(username, attrs)
    local plData = PlayersManager.GetOrCreateData(username)
    if attrs.isMIA ~= nil then
        plData.isMIA = attrs.isMIA
    end

    local cData = ServerData.Players.GetPlayersData()
    cData[username] = plData

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
    debugPrint("Checking player Status...")

    local Delay = require("ROK/Delay")
    Delay.Initialize()

    -- TODO Add SandboxVars to activate this stuff
    local username = playerObj:getUsername()
    local plData = PlayersManager.GetOrCreateData(username)


    -- Missing in action check
    local isMIA = plData.isMIA

    if isMIA then
        debugPrint("Player was set as Missing in Action, doing something that he won't forget!")

        Delay:set(1,function()
            --fixme after this players need to log back in again. Not optimal
            sendServerCommand(playerObj, EFT_MODULES.Common, "ForceRemove", {})
            PlayersManager.SetData(username, {isMIA = false})
        end)

        -- -- Teleport to an invalid zone first
        -- Delay:set(2, function()
        --     --sendServerCommand(playerObj, EFT_MODULES.Common, "Teleport", {x=3000,y=3000,z=0})

        -- end)

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