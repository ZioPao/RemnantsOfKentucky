require "PZEFT_debugtools"

local MODULE = "PZEFT"
local ServerCommands = {}

---Set client state if is in a raid or not
---@param args {value : boolean}
function ServerCommands.SetClientStateIsInRaid(args)

    ClientState.isInRaid = args.value
    if args.value == false then
        ClientState.extractionStatus = {}
    end

    triggerEvent("PZEFT_UpdateClientStatus", ClientState.isInRaid)

    -- TODO If someone quits the game while in a raid, the symbols are gonna stay until they join a new raid
    -- If we're in a raid, we need to reset the correct symbols. If we're not, we're gonna just clean them off the map
    ISWorldMap.HandleEFTExits(getPlayer():getPlayerNum(), not args.value)

end

function ServerCommands.CommitDieIfInRaid()
    if ClientState.isInRaid then
        ClientState.extractionStatus = {}
        local pl = getPlayer()
        pl:Kill(pl)
    end
end

---Teleport the player
---@param args {x : number, y : number, z : number}
function ServerCommands.Teleport(args)
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
