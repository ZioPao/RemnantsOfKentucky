require "PZ_EFT_debugtools"

ClientSafehouseInstanceHandler = ClientSafehouseInstanceHandler or {}

ClientSafehouseInstanceHandler.refreshSafehouseAllocation = function()
    sendClientCommand("PZEFT-Safehouse", "RequestSafehouseAllocation", {
        teleport = false
    })
end

--- This check is on the client side. Maybe somehow move to the server but that might be costly.
ClientSafehouseInstanceHandler.isInSafehouse = function()
    --if isDebugEnabled() then return end
    print("Running isInSafehouse")
    if not ClientState.IsInRaid then
        print("Player is not in a raid, running check for safehouse")
        local md = PZEFT_UTILS.GetPlayerModData()

        if not md.safehouse then
            return
        end

        local sq = getPlayer():getSquare()

        if not sq then
            return
        end

        if sq:getZ() ~= 0 then
            return false
        end

        local dimensions = PZ_EFT_CONFIG.SafehouseInstanceSettings.dimensions
        if getPlayer():isOutside() or not PZEFT_UTILS.IsPointWithinDimensions(md.safehouse.x, md.safehouse.y, dimensions.n,
            dimensions.s, dimensions.e, dimensions.w, sq:getX(), sq:getY()) then
            sendClientCommand("PZEFT-Safehouse", "RequestSafehouseAllocation", {
                teleport = true
            })
        end
    end
end

ClientSafehouseInstanceHandler.getSafehouse = function()
    local md = PZEFT_UTILS.GetPlayerModData()
    if not md.safehouse then
        return nil
    end

    return md.safehouse
end

--- On player initialise
--- Request safehouse allocation of player from server
---@param player IsoPlayer
ClientSafehouseInstanceHandler.onPlayerInit = function(player)
    print("Running onplayerinit")
    if player and player == getPlayer() then
        local md = PZEFT_UTILS.GetPlayerModData()
        if not md.safehouse then
            -- Request safe house allocation, which in turn will teleport the player to the assigned safehouse
            sendClientCommand("PZEFT-Safehouse", "RequestSafehouseAllocation", {
                teleport = true
            })
        end
    end

    -- TODO This probably needs to be moved somewhere else
    Events.OnPlayerUpdate.Remove(ClientSafehouseInstanceHandler.onPlayerInit)

end

Events.OnPlayerUpdate.Add(ClientSafehouseInstanceHandler.onPlayerInit)
