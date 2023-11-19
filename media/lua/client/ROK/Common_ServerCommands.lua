require "PZEFT_debugtools"

local MODULE = "PZEFT"
local ServerCommands = {}


---Triggers PZEFT_ClientModDataReady to initialize Global Mod Data on the client
---@param playerObj any
ServerCommands.SeverModDataReady = function(playerObj)
    triggerEvent("PZEFT_ClientModDataReady")
end

--- Sets pvpInstanceTable
--- Or use ClientCommands.print_pvp_currentinstance() to print current instance on the server's console
---@param instanceData pvpInstanceTable
ServerCommands.SetCurrentInstance = function(instanceData)
    local md = getPlayer():getModData()
    md.currentInstance = md.currentInstance or {}
    md.currentInstance = instanceData
end

--- Sets the amount of available instances to the client state
---@param args {amount : integer}
ServerCommands.ReceiveAmountAvailableInstances = function(args)
    ClientState.availableInstances = args.amount + 1
end

---Set client state if is in a raid or not
---@param args {value : boolean}
ServerCommands.SetClientStateIsInRaid = function(args)

    ClientState.isInRaid = args.value
    if args.value == false then
        ClientState.IsInExtractionArea = false
    end

    triggerEvent("PZEFT_UpdateClientStatus", ClientState.isInRaid)

    -- TODO If someone quits the game while in a raid, the symbols are gonna stay until they join a new raid
    -- If we're in a raid, we need to reset the correct symbols. If we're not, we're gonna just clean them off the map
    ISWorldMap.HandleEFTExits(getPlayer():getPlayerNum(), not args.value)

end

ServerCommands.CommitDieIfInRaid = function()

    if ClientState.isInRaid == false then return end

    ClientState.IsInExtractionArea = false      -- FIXME This is wrong!
    getPlayer():getBodyDamage():setHealth(0)
    
end

ServerCommands.Teleport = function(args)
    local player = getPlayer()
    player:setX(args.x)
    player:setY(args.y)
    player:setZ(args.z)
    player:setLx(args.x)
    player:setLy(args.y)
    player:setLz(args.z)
end
------------------------------------
local OnServerCommand = function(module, command, args)
    if (module == MODULE or module == MODULE) and ServerCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)
