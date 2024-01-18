---@class ClientState
---@field isInRaid boolean
---@field isStartingMatch boolean
---@field currentTime number
---@field extractionStatus table
---@field isAdminMode boolean Admin only
local ClientState = {
    isInRaid = false,
    isStartingMatch = false,
    currentTime = -1,
    extractionStatus = {},


    --* ADMIN ONLY
    isAdminMode = false
}

function ClientState.GetIsInRaid()
    return ClientState.isInRaid
end

function ClientState.ResetMatchValues()
    ClientState.isStartingMatch = false
    ClientState.extractionStatus = {}
end
Events.PZEFT_OnMatchEnd.Add(ClientState.ResetMatchValues)


-----------------------------------
--* Commands from the server

local ClientStateCommands = {}
local MODULE = EFT_MODULES.State

---Set client state if is in a raid or not
---@param args {value : boolean}
function ClientStateCommands.SetClientStateIsInRaid(args)

    ClientState.isInRaid = args.value


    if args.value == true then
        triggerEvent("PZEFT_OnMatchStart")
    else
        triggerEvent("PZEFT_OnMatchEnd")
    end

    triggerEvent("PZEFT_UpdateClientStatus", args.value)
end


function ClientStateCommands.CommitDieIfInRaid()
    if ClientState.GetIsInRaid() then
        ClientState.extractionStatus = {}
        local pl = getPlayer()
        pl:Kill(pl)
    end
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