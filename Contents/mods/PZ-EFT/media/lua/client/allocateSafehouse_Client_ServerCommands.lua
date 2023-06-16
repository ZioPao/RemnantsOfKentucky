local ServerCommands = {}

ServerCommands.SetSafehouse = function(safehouseInstance)
    print("Server Command - SetSafehouse");
    local player = getPlayer()
    local md = player:getModData()
    md.PZEFT = md.PZEFT or {}
    md.PZEFT.safehouse = safehouseInstance;
    PZEFT_UTILS.TeleportPlayer(player, safehouseInstance.x, safehouseInstance.y, safehouseInstance.z)
end

local OnServerCommand = function(module, command, args)
    if module == 'PZEFT' and ServerCommands[command] then
        ServerCommands[command](args)
    end
end


Events.OnServerCommand.Add(OnServerCommand)