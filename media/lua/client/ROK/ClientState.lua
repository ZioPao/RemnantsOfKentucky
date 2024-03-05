---@class ClientState
---@field isInRaid boolean
---@field isStartingMatch boolean
---@field currentTime number
---@field extractionTime number
---@field previousExtractionPointsStatus table
---@field extractionPointsStatus table
local ClientState = {
    isInRaid = false,
    isStartingMatch = false,
    currentTime = -1,


    isMatchRunning = false,
    extractionTime = -1,


    -- Extraction stuff
    previousExtractionPointsStatus = {},
    extractionPointsStatus = {}

}

--* Setters
---@param val boolean
function ClientState.SetIsInRaid(val)
    ClientState.isInRaid = val

    if val == true then
        triggerEvent("PZEFT_OnMatchStart")
    else
        triggerEvent("PZEFT_OnMatchEnd")
    end



    -- TODO Maybe too violent?
    triggerEvent("PZEFT_UpdateClientStatus", val)
end

---@param val number
function ClientState.SetCurrentTime(val)
    ClientState.currentTime = val
end

---@param val number
function ClientState.SetExtractionTime(val)
    ClientState.extractionTime = val
end

--* Getters

function ClientState.GetExtractionTime()
    return ClientState.extractionTime
end

function ClientState.GetIsInRaid()
    return ClientState.isInRaid
end

function ClientState.GetIsMatchRunning()
    return ClientState.isMatchRunning

end

function ClientState.ResetMatchValues()
    ClientState.isStartingMatch = false
    ClientState.isMatchRunning = false

    ClientState.previousExtractionPointsStatus = {}
    ClientState.extractionPointsStatus = {}
end
Events.PZEFT_OnMatchEnd.Add(ClientState.ResetMatchValues)


function ClientState.SetIsMatchRunning(value)
    ClientState.isMatchRunning = value
end

Events.PZEFT_OnMatchStart.Add(function ()
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

function ClientStateCommands.CommitDieIfInRaid()

    if ClientState.GetIsInRaid() == false then return end

    ClientState.extractionStatus = {}
    local ClientCommon = require("ROK/ClientCommon")
    ClientCommon.ForceKill()

    ClientState.SetIsInRaid(false)
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