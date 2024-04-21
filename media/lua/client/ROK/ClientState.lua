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

--* Getters

function ClientState.GetExtractionTime()
    return ClientState.extractionTime
end

function ClientState.GetIsInRaid()
    return ClientState.isInRaid
end

function ClientState.GetAvailableInstances()
    return ClientState.availableInstances
end

function ClientState.GetAlivePlayersAmount()
    return ClientState.alivePlayersAmount
end

function ClientState.GetIsMatchRunning()
    return ClientState.isMatchRunning
end

function ClientState.GetIsAutomaticStart()
    return ClientState.isAutomaticStart
end

function ClientState.GetIsStartingMatch()
    return ClientState.isStartingMatch
end

function ClientState.ResetMatchValues()
    ClientState.isStartingMatch = false
    ClientState.isMatchRunning = false

    ClientState.previousExtractionPointsStatus = {}
    ClientState.extractionPointsStatus = {}
end

Events.PZEFT_ClientNotInRaidAnymore.Add(ClientState.ResetMatchValues)


function ClientState.SetIsMatchRunning(value)


    -- Event
    if ClientState.isMatchRunning ~= value then
        if value then
            triggerEvent("PZEFT_MatchNowRunning")
        else
            triggerEvent("PZEFT_MatchNotRunningAnymore")

        end
    end

    ClientState.isMatchRunning = value
end

function ClientState.SetIsAutomaticStart(value)
    ClientState.isAutomaticStart = value
end

-- If the client is in a raid, force set that the match is running
Events.PZEFT_ClientNowInRaid.Add(function()
    ClientState.SetIsMatchRunning(true)
end)



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
    ClientState.isMatchRunning = args.value
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
