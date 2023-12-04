---@alias clientStateType {isInRaid : boolean, isStartingMatch : boolean, extractionStatus : table, currentTime : number, availableInstances : number, availableSafehouses : number}

---@type clientStateType
local ClientState = {
    isInRaid = false,
    isStartingMatch = false,
    currentTime = -1,
    extractionStatus = {},
}

-----------------------------------
--* Commands from the server

local ClientStateCommands = {}
local MODULE = EFT_MODULES.State

---Set client state if is in a raid or not
---@param args {value : boolean}
function ClientStateCommands.SetClientStateIsInRaid(args)

    ClientState.isInRaid = args.value

    if args.value == false then
        ClientState.extractionStatus = {}
        ClientState.isStartingMatch = false -- Reset this to prevent issues
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

return ClientState