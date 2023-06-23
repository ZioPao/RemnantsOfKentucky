require "ClientState"

local getAccountUpdateActive = false

--TODO: Maybe handle other event subscriptions to remove unnecessary overhead

--- Update event subscription
local function updateClientState()
    if ClientState.IsInRaid then
        if getAccountUpdateActive then
            Events.EveryOneMinute.Remove(ClientBankManager.getAccount)
            getAccountUpdateActive = false
        end
    else
        if not getAccountUpdateActive then
            Events.EveryOneMinute.Add(ClientBankManager.getAccount)
            getAccountUpdateActive = true
        end
    end
end

Events.EveryOneMinute.Add(updateClientState)
