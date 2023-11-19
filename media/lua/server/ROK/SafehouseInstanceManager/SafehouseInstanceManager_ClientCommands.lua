if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then
    return
end

require("ROK/DebugTools")
require "ROK/TeleportManager"

local MODULE = 'PZEFT-Safehouse'

local ClientCommands = {}

--- Sends command to client to set the player's safehouse
---@param playerObj IsoPlayer
---@param args table {teleport=true/false}
ClientCommands.RequestSafehouseAllocation = function(playerObj, args)
    if args.teleport then
        TeleportManager.Teleport(playerObj, (PZ_EFT_CONFIG.SpawnCell.x * 300) + 150,
            (PZ_EFT_CONFIG.SpawnCell.y * 300) + 150, 0)
    end

    local safehouseKey = SafehouseInstanceManager.getOrAssignSafehouse(playerObj)
    local safehouseInstance = SafehouseInstanceManager.getSafehouseInstanceByKey(safehouseKey)

    sendServerCommand(playerObj, MODULE, 'SetSafehouse', safehouseInstance)

    -- TODO Clean Inventory Box here to be sure that it doesn't contain old items.

    if args.teleport then
        print("Teleporting to instance from request safehouse allocation")
        TeleportManager.Teleport(playerObj, safehouseInstance.x, safehouseInstance.y, safehouseInstance.z)
    end

    if args.cleanStorage then
        sendServerCommand(playerObj, MODULE, 'CleanStorage', safehouseInstance)
    end
end

local OnClientCommand = function(module, command, playerObj, args)
    if module == MODULE and ClientCommands[command] then
        -- debugPrint("Client Command - " .. MODULE .. "." .. command)
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)