---@class ClientState
---@field isInRaid boolean
---@field isStartingMatch boolean
---@field isAutomaticStart boolean
---@field currentTime number
---@field extractionTime number
---@field availableInstances number
---@field alivePlayersAmount number
---@field previousExtractionPointsStatus table
---@field extractionPointsStatus table
local ClientState = {
    isInRaid = false,
    isStartingMatch = false,
    isAutomaticStart = false,
    currentTime = -1,

    -- Admin panels
    availableInstances = -1,
    alivePlayersAmount = -1,

    isMatchRunning = false,
    extractionTime = -1,


    -- Extraction stuff
    previousExtractionPointsStatus = {},
    extractionPointsStatus = {}

}

--* Setters
---@param val boolean
function ClientState.SetIsInRaid(val)
    local prev = ClientState.isInRaid
    ClientState.isInRaid = val

    if prev ~= ClientState.isInRaid then
        -- Notify that isInRaid has changed
        triggerEvent("PZEFT_IsInRaidChanged")

        -- More specific events
        if val == true then
            triggerEvent("PZEFT_ClientNowInRaid")
        else
            triggerEvent("PZEFT_ClientNotInRaidAnymore")
        end
    end
end

---@param val number
function ClientState.SetCurrentTime(val)
    ClientState.currentTime = val
end

---@param val number
function ClientState.SetExtractionTime(val)
    ClientState.extractionTime = val
end

---@param val number
function ClientState.SetAvailableInstances(val)
    ClientState.availableInstances = val
end

---@param val number
function ClientState.SetAlivePlayersAmount(val)
    ClientState.alivePlayersAmount = val
end

---@param val boolean
function ClientState.SetIsStartingMatch(val)
    ClientState.isStartingMatch = val
end

---@param value boolean
function ClientState.SetIsMatchRunning(value)

    debugPrint("Setting isMatchRunning="..tostring(value))
    debugPrint("Current isMatchRunning="..tostring(ClientState.isMatchRunning))
    -- Event
    if ClientState.isMatchRunning ~= value then
        if value then
            debugPrint("Triggering event PZEFT_MatchNowRunning")
            triggerEvent("PZEFT_MatchNowRunning")
        else
            debugPrint("Triggering event PZEFT_MatchNotRunningAnymore")
            triggerEvent("PZEFT_MatchNotRunningAnymore")
        end
    end

    ClientState.isMatchRunning = value
end

---@param value boolean
function ClientState.SetIsAutomaticStart(value)
    ClientState.isAutomaticStart = value
end

---@param val table
function ClientState.SetPreviousExtractionPointsStatus(val)
    ClientState.previousExtractionPointsStatus = val
end

---@param val table
function ClientState.SetExtractionPointsStatus(val)
    ClientState.extractionPointsStatus = val
end

--* Getters

---@return number
function ClientState.GetExtractionTime()
    return ClientState.extractionTime
end

---@return boolean
function ClientState.GetIsInRaid()
    return ClientState.isInRaid
end

---@return integer
function ClientState.GetAvailableInstances()
    return ClientState.availableInstances
end

---@return integer
function ClientState.GetAlivePlayersAmount()
    return ClientState.alivePlayersAmount
end

---@return boolean
function ClientState.GetIsMatchRunning()
    return ClientState.isMatchRunning
end

---@return boolean
function ClientState.GetIsAutomaticStart()
    return ClientState.isAutomaticStart
end

---@return boolean
function ClientState.GetIsStartingMatch()
    return ClientState.isStartingMatch
end

---@return table
function ClientState.GetPreviousExtractionPointsStatus()
    return ClientState.previousExtractionPointsStatus
end

---@return table
function ClientState.GetExtractionPointsStatus()
    return ClientState.extractionPointsStatus
end
-- -- If the client is in a raid, force set that the match is running
-- Events.PZEFT_ClientNowInRaid.Add(function()
--     ClientState.SetIsMatchRunning(true)
-- end)

function ClientState.ResetMatchValues()
    ClientState.SetIsStartingMatch(false)
    --ClientState.isMatchRunning = false This must be from serverside, not client-side
    ClientState.SetPreviousExtractionPointsStatus({})
    ClientState.SetExtractionPointsStatus({})
end

Events.PZEFT_ClientNotInRaidAnymore.Add(ClientState.ResetMatchValues)


-----------------------------------
--* Commands from the server

local ClientStateCommands = {}
local MODULE = EFT_MODULES.State


---@param args {extractionTime : number}
function ClientStateCommands.SetExtractionTime(args)
    ClientState.SetExtractionTime(args.extractionTime)
end

---Set client state if is in a raid or not
---@param args {value : boolean}
function ClientStateCommands.SetClientStateIsInRaid(args)
    debugPrint("SetClientStateIsInraid => " .. tostring(args.value))
    ClientState.SetIsInRaid(args.value)
end

function ClientStateCommands.SetClientStateIsMatchRunning(args)
    ClientState.SetIsMatchRunning(args.value)
end

function ClientStateCommands.SetClientStateIsAutomaticStart(args)
    ClientState.SetIsAutomaticStart(args.value)
end

function ClientStateCommands.CommitDieIfInRaid()
    if ClientState.GetIsInRaid() == false then return end

    ClientState.extractionStatus = {}
    local ClientCommon = require("ROK/ClientCommon")
    ClientCommon.ForceKill()

    ClientState.SetIsInRaid(false)
end

function ClientStateCommands.ForceQuit()
    getCore():quit()
    
    -- TODO Add notification
end

local function OnClientStateCommands(module, command, args)
    if (module == MODULE or module == MODULE) and ClientStateCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        ClientStateCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnClientStateCommands)

-----------------------------------

return ClientState
