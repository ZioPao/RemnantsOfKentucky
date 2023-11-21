---@alias clientStateType {isInRaid : boolean, extractionStatus : table, currentTime : number, availableInstances : number, availableSafehouses : number}

---@type clientStateType
ClientState = ClientState or {}

ClientState.isInRaid = false
ClientState.extractionStatus = {}

ClientState.currentTime = ""

ClientState.availableInstances = 0
ClientState.availableSafehouses = 0


-----------------------------------
--* Commands from the server

local ClientStateCommands = {}
local MODULE = "PZEFT-State"

--- Sets the amount of available instances to the client state
---@param args {amount : integer}
function ClientStateCommands.ReceiveAmountAvailableInstances(args)
    ClientState.availableInstances = args.amount + 1
end

---Set client state if is in a raid or not
---@param args {value : boolean}
function ClientStateCommands.SetClientStateIsInRaid(args)

    ClientState.isInRaid = args.value
    if args.value == false then
        ClientState.extractionStatus = {}
    end

    triggerEvent("PZEFT_UpdateClientStatus", ClientState.isInRaid)

    -- TODO If someone quits the game while in a raid, the symbols are gonna stay until they join a new raid
    -- If we're in a raid, we need to reset the correct symbols. If we're not, we're gonna just clean them off the map
    ISWorldMap.HandleEFTExits(getPlayer():getPlayerNum(), not args.value)

end

function ClientStateCommands.CommitDieIfInRaid()
    if ClientState.isInRaid then
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
--* Events, client only *--

-- If player in raid, set that they're not in it anymore
local function OnPlayerExit()
    if ClientState.isInRaid == false then return end

    sendClientCommand("PZEFT-PvpInstances", "RemovePlayer", {})
    ClientState.isInRaid = false
end

Events.OnPlayerDeath.Add(OnPlayerExit)
Events.OnDisconnect.Add(OnPlayerExit)