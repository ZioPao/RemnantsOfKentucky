require "ClientState"

local getAccountUpdateActive = false
local isInSafehouseUpdateActive = false
local isRefreshSafehouseAllocationUpdateActive = false
--TODO: Maybe handle other event subscriptions to remove unnecessary overhead

local function EveryOneMinute_InRaid_Events()
    if getAccountUpdateActive then
        getAccountUpdateActive = false
        Events.EveryOneMinute.Remove(ClientBankManager.getAccount)
    end
    if isInSafehouseUpdateActive then
        isInSafehouseUpdateActive = false
        Events.EveryOneMinute.Remove(ClientSafehouseInstanceHandler.isInSafehouse)
    end
    if isRefreshSafehouseAllocationUpdateActive then
        isRefreshSafehouseAllocationUpdateActive = false
        Events.EveryOneMinute.Remove(ClientSafehouseInstanceHandler.refreshSafehouseAllocation)
    end
    
end

local function EveryOneMinute_Not_InRaid_Events()
    if not getAccountUpdateActive then
        getAccountUpdateActive = true
        Events.EveryOneMinute.Add(ClientBankManager.getAccount)
    end
    if not isInSafehouseUpdateActive then
        isInSafehouseUpdateActive = true
        Events.EveryOneMinute.Add(ClientSafehouseInstanceHandler.isInSafehouse)
    end
    if not isRefreshSafehouseAllocationUpdateActive then
        isRefreshSafehouseAllocationUpdateActive = true
        Events.EveryOneMinute.Add(ClientSafehouseInstanceHandler.refreshSafehouseAllocation)
    end
end

--- Update event subscription
local function updateClientState()
    if ClientState.IsInRaid then
        EveryOneMinute_InRaid_Events()
    else
        EveryOneMinute_Not_InRaid_Events()
    end
end

Events.EveryOneMinute.Add(updateClientState)