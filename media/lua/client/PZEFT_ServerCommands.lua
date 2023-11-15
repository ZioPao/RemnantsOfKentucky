require "PZEFT_debugtools"

local ServerCommands = {}

local MODULE = 'PZEFT'

ServerCommands.SeverModDataReady = function(playerObj)
    triggerEvent("PZEFT_ClientModDataReady")
end

--- Sets {id, x, y, spawnPoints = {{x=0,y=0,z=0},{x=0,y=0,z=0}}, extractionPoints = {{x=0,y=0,z=0},{x=0,y=0,z=0}}}
--- Or use ClientCommands.print_pvp_currentinstance() to print current instance on the server's console
ServerCommands.SetCurrentInstance = function(instanceData)
    local md = getPlayer():getModData()
    md.currentInstance = md.currentInstance or {}
    md.currentInstance = instanceData
end

--- Sets the amount of available instances to the client state
ServerCommands.ReceiveAmountAvailableInstances = function(args)
    ClientState.availableInstances = args.amount + 1
end

---Set client state if is in a raid or not
---@param args {value : boolean}
ServerCommands.SetClientStateIsInRaid = function(args)

    ClientState.IsInRaid = args.value
    if args.value == false then
        ClientState.IsInExtractionArea = false
    end

    triggerEvent("PZEFT_UpdateClientStatus", ClientState.IsInRaid)

    -- TODO If someone quits the game while in a raid, the symbols are gonna stay until they join a new raid
    -- If we're in a raid, we need to reset the correct symbols. If we're not, we're gonna just clean them off the map
    ISWorldMap.HandleEFTExits(getPlayer():getPlayerNum(), not args.value)

end

ServerCommands.CommitDieIfInRaid = function()
    if ClientState.IsInRaid then
        ClientState.IsInExtractionArea = false
        getPlayer():getBodyDamage():setHealth(0)
    end
end

-------------------------

local OnServerCommand = function(module, command, args)
    if module == MODULE and ServerCommands[command] then
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)