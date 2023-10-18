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

ServerCommands.SetClientStateIsInRaid = function(args)

    print("Received new status for isInRaid = " .. tostring(args.value))

    ClientState.IsInRaid = args.value
    if args.value == false then
        ClientState.IsInExtractionArea = false
    end
end

ServerCommands.CommitDieIfInRaid = function()
    if ClientState.IsInRaid then
        ClientState.IsInExtractionArea = false
        getPlayer():getBodyDamage():setHealth(0);
    end
end

local OnServerCommand = function(module, command, args)
    if module == MODULE and ServerCommands[command] then
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)