require("ROK/DebugTools")

ClientSafehouseInstanceHandler = ClientSafehouseInstanceHandler or {}

ClientSafehouseInstanceHandler.refreshSafehouseAllocation = function()
    sendClientCommand("PZEFT-Safehouse", "RequestSafehouseAllocation", {
        teleport = false
    })
end

--- This check is on the client side. Maybe somehow move to the server but that might be costly.
ClientSafehouseInstanceHandler.isInSafehouse = function()
    --if isDebugEnabled() then return end
    --print("Running isInSafehouse")
    if not ClientState.isInRaid then
        --print("Player is not in a raid, running check for safehouse")
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

---@return table? {ItemContainer}
ClientSafehouseInstanceHandler.GetCrates = function()
    local cratesTable = {}

    local safehouse = ClientSafehouseInstanceHandler.getSafehouse()
    if safehouse == nil then
        print("ERROR: can't find safehouse!")
        return
    end
    for _, group in pairs(PZ_EFT_CONFIG.SafehouseInstanceSettings.safehouseStorage) do
        local sq = getCell():getGridSquare(safehouse.x + group.x, safehouse.y + group.y, 0)
        if sq == nil then
            print("ERROR: Square not found while searching for crates")
            break
        end
        local objects = sq:getObjects()
        for i = 0, objects:size() - 1 do
            local obj = objects:get(i)
            local container = obj:getContainer()
            if container then table.insert(cratesTable, container) end
        end
    end

    print("Found " .. #cratesTable .. " crates")

    return cratesTable
end

ClientSafehouseInstanceHandler.wipeCrates = function()
    for _, group in pairs(PZ_EFT_CONFIG.SafehouseInstanceSettings.safehouseStorage) do
        local sq = getCell():getGridSquare(group.x, group.y, 0)
        local objects = sq:getObjects()
        local inventoryContainer
        for i = 1, objects:size() do
            if instanceof(objects:get(i), "InventoryItem") then
                inventoryContainer = objects:get(i):getContainer()
                if inventoryContainer then
                    inventoryContainer:clear()
                else
                    error("Crate found, but no InventoryContainer")
                end
            end
        end
    end
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
