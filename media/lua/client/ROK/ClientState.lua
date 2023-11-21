---@alias clientStateType {isInRaid : boolean, extractionStatus : table, currentTime : number, availableInstances : number, availableSafehouses : number}

---@type clientStateType
ClientState = ClientState or {}

ClientState.isInRaid = false
ClientState.extractionStatus = {}

ClientState.currentTime = ""

ClientState.availableInstances = 0
ClientState.availableSafehouses = 0
