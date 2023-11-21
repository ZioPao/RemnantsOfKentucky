---@alias clientStateType {isInRaid : boolean, extractionStatus : table, currentTime : number, availableInstances : number, availableSafehouses : number}

---@type clientStateType
ClientState = ClientState or {}

ClientState.isInRaid = false
ClientState.extractionStatus = {}

ClientState.currentTime = ""

ClientState.availableInstances = 0
ClientState.availableSafehouses = 0


-----------------------------------
--* Events, client only *--

-- If player in raid, set that they're not in it anymore
local function OnPlayerExit()
    if ClientState.isInRaid == false then return end

    sendClientCommand("PZEFT-PvpInstances", "RemovePlayer", {})
    ClientState.isInRaid = false
end

Events.OnPlayerDeath.Add(OnPlayerExit)
Events.OnDisconnect.Add(OnPlayerExit)