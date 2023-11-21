if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then
    return
end

------------------------

---@class TeleportManager
local TeleportManager = {}

--- Handle teleportation from the client side
---@param player IsoPlayer
---@param x number
---@param y number
---@param z number
function TeleportManager.Teleport(player, x, y, z)
    debugPrint("TeleportManager.Teleport: Teleporting player")
    sendServerCommand(player, "PZEFT", "Teleport", {
        x = x,
        y = y,
        z = z
    })
end


return TeleportManager
