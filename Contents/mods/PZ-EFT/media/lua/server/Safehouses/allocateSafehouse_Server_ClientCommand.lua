local ClientCommands = {}

ClientCommands.OnPlayerJoin = function(_, args)
    local player = getPlayerByOnlineID(args.playerID)

    local safehouseKey = PlayerSafehouseManager.getOrAssignSafehouse(player)
    local safehouseInstance = SafehouseInstanceManager.getSafehouseInstanceByKey(safehouseKey)

    sendServerCommand(player, 'PZEFT_AllocateSafehouse', 'SetSafehouse', safehouseInstance);
end

local OnClientCommand = function(module, command, playerObj, args)
    if module == 'PZEFT_AllocateSafehouse' and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end


Events.OnClientCommand.Add(OnClientCommand)