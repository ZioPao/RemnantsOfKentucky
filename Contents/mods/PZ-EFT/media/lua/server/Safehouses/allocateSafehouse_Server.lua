local firstSafehouse = {
    relative = {
        x = 8,
        y = 19,
        z = 0
    }
}

local safehouseGrid = {
    x = {
        count = 5,
        spacing = 60
    },
    y = {
        count = 5,
        spacing = 60
    }
}

local safehouseInstances = {} -- key (SafehouseInstanceManager.getCoordinateID): "x-y-z", value: {x=wx, y=wy, z=wz}
local assignedSafehouses = {} -- key (SafehouseInstanceManager.getCoordinateID): "x-y-z", value: playerOnlineID

SafehouseInstanceManager = SafehouseInstanceManager or {}

--- Get coordinate key string by world X, world Y, worldZ
---@param wx number
---@param wy number
---@param wz number
SafehouseInstanceManager.getCoordinateID = function(wx, wy, wz)
    return wx .. "-" .. wy .. "-" .. wz
end

--- Load safehouse instances using relative cell coordinates.
--- Call this multiple times with different cells if safehouses take up more than one cell
---@param cellX number
---@param cellY number
SafehouseInstanceManager.loadSafehouseInstances = function(cellX, cellY)
    for y = 0, safehouseGrid.y.count - 1 do
        for x = 0, safehouseGrid.x.count - 1 do
            local relativeX = firstSafehouse.relative.x + (x * safehouseGrid.x.spacing)
            local relativeY = firstSafehouse.relative.y + (y * safehouseGrid.y.spacing)
            local relativeZ = firstSafehouse.relative.z

            local wX = (cellX * 300) + relativeX
            local wY = (cellY * 300) + relativeY
            local wZ = relativeZ

            safehouseInstances[SafehouseInstanceManager.getCoordinateID(wX, wY, wZ)] = {
                x = wX,
                y = wY,
                z = wZ
            }
        end
    end
end

-- TODO Check if the same playerOnlineID persists after death/reconnect
--- Assign a safehouse instance by key to player online ID
---@param key string
---@param playerOnlineID integer
SafehouseInstanceManager.assignSafehouseInstanceToPlayer = function(key, playerOnlineID)
    assignedSafehouses[key] = playerOnlineID
    return key
end

--- Get player safehouse by player online ID
---@param playerOnlineID integer
SafehouseInstanceManager.getPlayerSafehouseKey = function(playerOnlineID)
    for key, value in pairs(assignedSafehouses) do
        if assignedSafehouses[key] == playerOnlineID then
            return key
        end
    end
end

--- Unassign a safehouse instance 
---@param key string
SafehouseInstanceManager.unassignSafehouseInstance = function(key)
    local safehouseInstance = safehouseInstances[key];
    assignedSafehouses[key] = nil
end

--- Get safehouse instance information by key
---@param key string
SafehouseInstanceManager.getSafehouseInstanceByKey = function(key)
    return safehouseInstances[key]
end

--- Get the key of the next free safehouse, if any
SafehouseInstanceManager.getNextFreeSafehouseKey = function()
    if SafehouseInstanceManager.getFreeSafehouseCount() <= 0 then
        return nil
    end

    for key, value in pairs(safehouseInstances) do
        if not assignedSafehouses[key] then
            return key
        end
    end
end

--- Get count of free safehouses
SafehouseInstanceManager.getFreeSafehouseCount = function()
    local totalSafehouseCount = #safehouseInstances
    local totalAssignedCount = #assignedSafehouses
    
    return totalSafehouseCount - totalAssignedCount
end

--- Get count of assigned safehouses
SafehouseInstanceManager.getAssignedSafehouseCount = function()
    return #assignedSafehouses
end

--- Get count of total safehouse instances
SafehouseInstanceManager.getTotalSafehouseInstanceCount = function()
    return #safehouseInstances
end

PlayerSafehouseManager = PlayerSafehouseManager or {}

--- Get or assign safehouse and get its key.
---@param player IsoPlayer
PlayerSafehouseManager.getOrAssignSafehouse = function(player)
    local id = player:getOnlineID()

    local playerSafehouseKey = SafehouseInstanceManager.getPlayerSafehouseKey(id)

    if not playerSafehouseKey then
        playerSafehouseKey = SafehouseInstanceManager.getNextFreeSafehouseKey()

        if not playerSafehouseKey then
            warn("PlayerSafehouseManager.getOrAssignSafehouse: No free safehouses found for player.")
            return
        end

        SafehouseInstanceManager.assignSafehouseInstanceToPlayer(playerSafehouseKey, id)
    end

    return playerSafehouseKey
end
