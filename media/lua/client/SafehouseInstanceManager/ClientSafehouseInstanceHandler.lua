require "PZ_EFT_debugtools"

ClientSafehouseInstanceHandler = ClientSafehouseInstanceHandler or {}

--- On create player
--- Teleport player to a "neutral"square to remove from any potential safehouse
--- Request safehouse allocation of player from server
---@param player IsoPlayer
ClientSafehouseInstanceHandler.onCreatePlayer = function(_, player)
    if player == getPlayer() then
        -- On join, request safehouse allocation data
        debugPrint("On Create Player, RequestSafehouseAllocation")

        -- Request safe house allocation, which in turn will teleport the player to the assigned safehouse
        sendClientCommand("PZEFT-Safehouse", "RequestSafehouseAllocation", {
            teleport = true
        })
    end
end

Events.OnCreatePlayer.Add(ClientSafehouseInstanceHandler.onCreatePlayer)

ClientSafehouseInstanceHandler.refreshSafehouseAllocation = function()
    sendClientCommand("PZEFT-Safehouse", "RequestSafehouseAllocation", {
        teleport = false
    })
end

--- This check is on the client side. Maybe somehow move to the server but that might be costly.
ClientSafehouseInstanceHandler.isInSafehouse = function()
    local player = getPlayer()
    if not ClientState.IsInRaid then
        local player = getPlayer()
        local md = player:getModData()

        if not md.PZEFT or not md.PZEFT.safehouse then
            return
        end

        local sq = player:getSquare()

        if not sq then return end

        if sq:getZ() ~= 0 then
            return false;
        end

        local dimensions = PZ_EFT_CONFIG.SafehouseInstanceSettings.dimensions
        if not PZEFT_UTILS.IsPointWithinDimensions(md.PZEFT.safehouse.x, md.PZEFT.safehouse.y, dimensions.n,
            dimensions.s, dimensions.e, dimensions.w, sq:getX(), sq:getY()) then
            sendClientCommand("PZEFT-Safehouse", "RequestSafehouseAllocation", {
                teleport = true
            })
        end
    end
end
