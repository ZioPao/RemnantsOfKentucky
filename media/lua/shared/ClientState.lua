---@alias client_state {IsInRaid : boolean, ExtractionStatus : table, currentTime : number, availableInstances : number, availableSafehouses : number}

---@type client_state
ClientState = ClientState or {}

ClientState.IsInRaid = false    -- TODO Lowercase!
ClientState.ExtractionStatus = {}

ClientState.currentTime = ""

ClientState.availableInstances = 0
ClientState.availableSafehouses = 0
