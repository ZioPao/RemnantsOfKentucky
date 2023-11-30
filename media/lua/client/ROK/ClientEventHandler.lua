local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")
local ClientBankManager = require("ROK/Economy/ClientBankManager")
local ClientState = require("ROK/ClientState")
-----------------------------

local isInSafehouseUpdateActive = false
local isRefreshSafehouseAllocationUpdateActive = false

--TODO: Maybe handle other event subscriptions to remove unnecessary overhead

local function EveryOneMinute_InRaid_Events()
    if isInSafehouseUpdateActive then
        isInSafehouseUpdateActive = false
        Events.EveryOneMinute.Remove(SafehouseInstanceHandler.HandlePlayerInSafehouse)
    end
    if isRefreshSafehouseAllocationUpdateActive then
        isRefreshSafehouseAllocationUpdateActive = false
        Events.EveryOneMinute.Remove(SafehouseInstanceHandler.RefreshSafehouseAllocation)
    end
end

local function EveryOneMinute_Not_InRaid_Events()
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
local function UpdateClientState()
    if ClientState.isInRaid then
        EveryOneMinute_InRaid_Events()
    else
        EveryOneMinute_Not_InRaid_Events()
    end
end

Events.EveryOneMinute.Add(UpdateClientState)

-- If player in raid, set that they're not in it anymore
local function OnPlayerExit()
    if ClientState.isInRaid == false then return end

    sendClientCommand(EFT_MODULES.Match, "RemovePlayer", {})
    ClientState.isInRaid = false
end

Events.OnPlayerDeath.Add(OnPlayerExit)
Events.OnDisconnect.Add(OnPlayerExit)




-- local function OnCreatePlayer()
--     if not SafehouseInstanceHandler.IsInSafehouse() then
--         local BlackScreen = require("ROK/UI/BeforeMatch/BlackScreen")
--         BlackScreen.Open()
--     end

-- end


-- Events.OnCreatePlayer.Add(OnCreatePlayer)


---------------------------------------
--* Admin only *--

local function ClearZombiesNearSafehouses()
    -- TODO Bit inefficient, we should select a single admin instead of running this on every one. Also, not sure if works at all
    if not isAdmin() then return end

    for _,v in ipairs(PZ_EFT_CONFIG.SafehouseCells)do
        zpopClearZombies(v.x,v.y)
    end

end

Events.EveryOneMinute.Add(ClearZombiesNearSafehouses)