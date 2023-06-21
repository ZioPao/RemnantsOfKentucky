local ClientCommands = {}

--- Sends command to client to set the player's safehouse
---@param playerObj IsoPlayer
ClientCommands.RequestSafehouseAllocation = function(playerObj, _)
    local safehouseKey = SafehouseInstanceManager.getOrAssignSafehouse(playerObj)
    local safehouseInstance = SafehouseInstanceManager.getSafehouseInstanceByKey(safehouseKey)

    sendServerCommand(playerObj, 'PZEFT-Safehouse', 'SetSafehouse', safehouseInstance)
    PZEFT_UTILS.TeleportPlayer(playerObj, safehouseInstance.x, safehouseInstance.y, safehouseInstance.z)
end

local OnClientCommand = function(module, command, playerObj, args)
    if module == 'PZEFT-Safehouse' and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)
