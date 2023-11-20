-- TODO Why is it in shared?

---@alias clientStateType {isInRaid : boolean, extractionStatus : table, currentTime : number, availableInstances : number, availableSafehouses : number}

---@type clientStateType
ClientState = ClientState or {}

ClientState.isInRaid = false    -- TODO Lowercase!
ClientState.extractionStatus = {}

ClientState.currentTime = ""

ClientState.availableInstances = 0
ClientState.availableSafehouses = 0
