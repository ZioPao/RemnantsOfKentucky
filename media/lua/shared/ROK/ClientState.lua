-- TODO Why is it in shared?

---@alias client_state {isInRaid : boolean, extractionStatus : table, currentTime : number, availableInstances : number, availableSafehouses : number}

---@type client_state
ClientState = ClientState or {}

ClientState.isInRaid = false    -- TODO Lowercase!
ClientState.extractionStatus = {}

ClientState.currentTime = ""

ClientState.availableInstances = 0
ClientState.availableSafehouses = 0
