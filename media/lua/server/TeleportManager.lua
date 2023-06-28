if (not isServer()) and not (not isServer() and not isClient()) then return end

TeleportManager = TeleportManager or {}

--- Handle teleportation from the client side
TeleportManager.Teleport = function(player, x, y, z)
    sendServerCommand(player, "PZ-EFT-TELEPORT", "Teleport", {x = x, y = y, z = z})
end