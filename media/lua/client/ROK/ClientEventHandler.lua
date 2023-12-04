local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")
local ClientState = require("ROK/ClientState")
local BlackScreen = require("ROK/UI/BeforeMatch/BlackScreen")
-----------------------------

local isInSafehouseUpdateActive = false
local isRefreshSafehouseAllocationUpdateActive = false

--TODO: Maybe handle other event subscriptions to remove unnecessary overhead




local ClientEvents = {}

-- ClientEvents.list = {
--     "isSafehouseUpdate", "safehouseAllocationUpdate"
-- }

-- ClientEvents.tab = {
--     inSafehouseUpdate = {check = false, func = SafehouseInstanceHandler.HandlePlayerInSafehouse},
--     safehouseAllocationUpdate = { check = false, func = SafehouseInstanceHandler.RefreshSafehouseAllocation},
-- }


function ClientEvents.WhileInRaid()

    -- for i=1, #ClientEvents.list do
    --     local event = ClientEvents.list[i]
    --     if ClientEvents.tab[event].check then
    --         ClientEvents.tab[event].check = true
    --         Events.EveryOneMinute.Remove(ClientEvents.tab[event].func)
    --     end
    -- end


    if isInSafehouseUpdateActive then
        isInSafehouseUpdateActive = false
        Events.EveryOneMinute.Remove(SafehouseInstanceHandler.HandlePlayerInSafehouse)
    end
    if isRefreshSafehouseAllocationUpdateActive then
        isRefreshSafehouseAllocationUpdateActive = false
        Events.EveryOneMinute.Remove(SafehouseInstanceHandler.RefreshSafehouseAllocation)
    end
end

function ClientEvents.WhileInSafehouse()
    if not isInSafehouseUpdateActive then
        isInSafehouseUpdateActive = true
        Events.EveryOneMinute.Add(SafehouseInstanceHandler.HandlePlayerInSafehouse)
    end
    if not isRefreshSafehouseAllocationUpdateActive then
        isRefreshSafehouseAllocationUpdateActive = true
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




--* Raid handling
-- If player in raid, set that they're not in it anymore
local function OnPlayerExit()
    if ClientState.isInRaid == false then return end

    sendClientCommand(EFT_MODULES.Match, "RemovePlayer", {})
    ClientState.isInRaid = false
end

Events.OnPlayerDeath.Add(OnPlayerExit)
Events.OnDisconnect.Add(OnPlayerExit)



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
    BlackScreen.Open()


    Events.OnPlayerUpdate.Remove(OnPlayerInit)
end

Events.OnPlayerUpdate.Add(OnPlayerInit)


--end


--Events.OnLoad.Add(OnLoadAskServerData)

-- local function OnLoad()
--     if not SafehouseInstanceHandler.IsInSafehouse() then
--         local BlackScreen = require("ROK/UI/BeforeMatch/BlackScreen")
--         -- TODO This is so early that it overrides the reference, fuck sake
--         BlackScreen.Open()
--     end

-- end

-- Events.OnLoad.Add(OnLoad)