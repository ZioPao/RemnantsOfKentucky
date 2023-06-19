local ClientCommands = {}

--- Sends command to client to set the player's safehouse
---@param playerObj IsoPlayer
ClientCommands.RequestSafehouseAllocation = function(playerObj, _)
    local safehouseKey = SafehouseInstanceManager.getOrAssignSafehouse(playerObj)
    local safehouseInstance = SafehouseInstanceManager.getSafehouseInstanceByKey(safehouseKey)

    triggerEvent("OnServerCommand", "PZEFT", "SetSafehouse", safehouseInstance); -- TODO: Remove, SP support for testing
    sendServerCommand(playerObj, 'PZEFT', 'SetSafehouse', safehouseInstance)
end

local OnClientCommand = function(module, command, playerObj, args)
    if module == 'PZEFT' and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)
