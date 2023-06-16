local ClientCommands = {}

ClientCommands.RequestSafehouseAllocation = function(playerObj, _)
    local safehouseKey = PlayerSafehouseManager.getOrAssignSafehouse(playerObj)
    local safehouseInstance = SafehouseInstanceManager.getSafehouseInstanceByKey(safehouseKey)

    --TODO: REMOVE FOR SP DEBUG
    triggerEvent("OnServerCommand", "PZEFT", "SetSafehouse", safehouseInstance);
    sendServerCommand(playerObj, 'PZEFT', 'SetSafehouse', safehouseInstance)
end

local OnClientCommand = function(module, command, playerObj, args)
    if module == 'PZEFT' and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end


Events.OnClientCommand.Add(OnClientCommand)