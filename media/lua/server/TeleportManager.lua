if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then
    return
end

TeleportManager = TeleportManager or {}

--- Handle teleportation from the client side
TeleportManager.Teleport = function(player, x, y, z)
    print("TeleportManager.Teleport: Teleporting player")
    sendServerCommand(player, "PZEFT-TELEPORT", "Teleport", {
        x = x,
        y = y,
        z = z
    })
end
