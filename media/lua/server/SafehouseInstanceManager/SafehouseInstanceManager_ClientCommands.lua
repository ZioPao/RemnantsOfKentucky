require "PZ_EFT_debugtools"

local MODULE = 'PZEFT-Safehouse'

local ClientCommands = {}

--- Sends command to client to set the player's safehouse
---@param playerObj IsoPlayer
ClientCommands.RequestSafehouseAllocation = function(playerObj, _)
    local safehouseKey = SafehouseInstanceManager.getOrAssignSafehouse(playerObj)
    local safehouseInstance = SafehouseInstanceManager.getSafehouseInstanceByKey(safehouseKey)

    sendServerCommand(playerObj, MODULE, 'SetSafehouse', safehouseInstance)
    PZEFT_UTILS.TeleportPlayer(playerObj, safehouseInstance.x, safehouseInstance.y, safehouseInstance.z)
end

local OnClientCommand = function(module, command, playerObj, args)
    if module == MODULE and ClientCommands[command] then
        debugPrint("Client Command - " .. MODULE .. "." .. command)
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)
