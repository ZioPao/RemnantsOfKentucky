require "PZ_EFT_debugtools"

local MODULE = 'PZEFT-Safehouse'

local ClientCommands = {}

--- Sends command to client to set the player's safehouse
---@param playerObj IsoPlayer
---@param args Table {teleport=true/false}
ClientCommands.RequestSafehouseAllocation = function(playerObj, args)
    if args.teleport then
        PZEFT_UTILS.TeleportPlayer(playerObj,302,302,0)
    end

    local safehouseKey = SafehouseInstanceManager.getOrAssignSafehouse(playerObj)
    local safehouseInstance = SafehouseInstanceManager.getSafehouseInstanceByKey(safehouseKey)

    sendServerCommand(playerObj, MODULE, 'SetSafehouse', safehouseInstance)

    if args.teleport then
        PZEFT_UTILS.TeleportPlayer(playerObj, safehouseInstance.x, safehouseInstance.y, safehouseInstance.z)
    end
end

local OnClientCommand = function(module, command, playerObj, args)
    if module == MODULE and ClientCommands[command] then
        debugPrint("Client Command - " .. MODULE .. "." .. command)
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)
