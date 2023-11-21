require "ROK/ClientData"

-- If player in raid, set that they're not in it anymore
local function OnPlayerDeath()
    if ClientState.isInRaid == false then return end

    sendClientCommand("PZEFT-PvpInstances", "RemovePlayer", {})
    ClientState.isInRaid = false
end

Events.OnPlayerDeath.Add(OnPlayerDeath)