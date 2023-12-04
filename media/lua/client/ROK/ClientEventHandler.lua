local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")
local ClientState = require("ROK/ClientState")
local ClientCommon = require("ROK/ClientCommon")
local BlackScreen = require("ROK/UI/BeforeMatch/BlackScreen")
-----------------------------

local ClientEvents = {}

ClientEvents.inSafehouseUpdate = false
ClientEvents.refreshSafehouseAllocationUpdate = false


function ClientEvents.WhileInRaid()
    if ClientEvents.inSafehouseUpdate then
        ClientEvents.inSafehouseUpdate = false
        Events.EveryOneMinute.Remove(SafehouseInstanceHandler.HandlePlayerInSafehouse)
    end
    if ClientEvents.refreshSafehouseAllocationUpdate then
        ClientEvents.refreshSafehouseAllocationUpdate = false
        Events.EveryOneMinute.Remove(SafehouseInstanceHandler.RefreshSafehouseAllocation)
    end
end

function ClientEvents.WhileInSafehouse()
    if not ClientEvents.inSafehouseUpdate then
        ClientEvents.inSafehouseUpdate = true
        Events.EveryOneMinute.Add(SafehouseInstanceHandler.HandlePlayerInSafehouse)
    end
    if not ClientEvents.refreshSafehouseAllocationUpdate then
        ClientEvents.refreshSafehouseAllocationUpdate = true
        Events.EveryOneMinute.Add(SafehouseInstanceHandler.RefreshSafehouseAllocation)
    end

    -- TODO Move this away, just for test
    sendClientCommand(EFT_MODULES.PvpInstances, "GetAmountAvailableInstances", {})

end

--- Update event subscription
function ClientEvents.UpdateEvents()
    if ClientState.isInRaid then
        ClientEvents.WhileInRaid()
    else
        ClientEvents.WhileInSafehouse()
    end
end
Events.EveryOneMinute.Add(ClientEvents.UpdateEvents)


-----------------------------------
--* Raid handling

-- If player in raid, set that they're not in it anymore
local function OnPlayerExit()
    if ClientState.isInRaid == false then return end

    sendClientCommand(EFT_MODULES.Match, "RemovePlayer", {})
    

    -- Reset buttons 
    ButtonManager.firstInit = true
end

Events.OnPlayerDeath.Add(OnPlayerExit)
Events.OnDisconnect.Add(OnPlayerExit)

-----------------------------------
--* Startup handling

--- On player initialise, request safehouse allocation of player from server
---@param player IsoPlayer
local function OnPlayerInit(player)
    debugPrint("Running safehouse instance handler onplayerinit")
    if player == nil or player ~= getPlayer() then return end

    --* Safehouse handling
    local md = PZEFT_UTILS.GetPlayerModData()
    if not md.safehouse then
        -- Request safe house allocation, which in turn will teleport the player to the assigned safehouse
        sendClientCommand(EFT_MODULES.Safehouse, "RequestSafehouseAllocation", {
            teleport = true
        })
    end

    --* Shop Items
    debugPrint("Sending TransmitShopItems now that player is in")
    sendClientCommand(EFT_MODULES.Shop, 'TransmitShopItems', {})

    --* Opens black screen
    -- TODO Still broken when outside of a safehouse at startup
    --BlackScreen.Open()


    Events.OnPlayerUpdate.Remove(OnPlayerInit)
end

Events.OnPlayerUpdate.Add(OnPlayerInit)

-----------------------------------
--* Player setup handling, first time they log in

---@param playerObj IsoPlayer
local function GiveStarterKit(playerObj)
    ClientCommon.GiveStarterKit(playerObj, true)
end


Events.OnNewGame.Add(GiveStarterKit)
