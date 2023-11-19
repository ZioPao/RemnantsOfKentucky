if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then
    return
end

------------------------


-- TODO Make it local

---@class TeleportManager
TeleportManager = TeleportManager or {}

--- Handle teleportation from the client side
TeleportManager.Teleport = function(player, x, y, z)
    print("TeleportManager.Teleport: Teleporting player")
    sendServerCommand(player, "PZEFT", "Teleport", {
        x = x,
        y = y,
        z = z
    })
end


--return TeleportManager
