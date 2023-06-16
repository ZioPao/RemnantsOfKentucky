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
local assignedSafehouses = {} -- key (SafehouseInstanceManager.getCoordinateID): "x-y-z", value: playerSteamID

local loaded = false;

SafehouseInstanceManager = SafehouseInstanceManager or {}

-- Testing, can remove later --

SafehouseInstanceManager.displaySafehouseInstances = function()
    for key, value in pairs(safehouseInstances) do
        print("Key: " .. key)
    end
end

SafehouseInstanceManager.displayAssignedSafehouseInstances = function()
    for key, value in pairs(assignedSafehouses) do
        print("Key: " .. key)
    end
end

SafehouseInstanceManager.isLoaded = function()
    print(loaded)
    return loaded
end

------------------------

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
    loaded = true;
end

-- TODO Check if the same playerSteamID persists after death/reconnect
--- Assign a safehouse instance by key to player online ID
---@param key string
---@param playerSteamID integer
SafehouseInstanceManager.assignSafehouseInstanceToPlayer = function(key, playerSteamID)
    assignedSafehouses[key] = playerSteamID
    return key
end

--- Get player safehouse by player online ID
---@param playerSteamID integer
SafehouseInstanceManager.getPlayerSafehouseKey = function(playerSteamID)
    for key, value in pairs(assignedSafehouses) do
        if assignedSafehouses[key] == playerSteamID then
            return key
        end
    end
end

--- Unassign a safehouse instance 
---@param key string
SafehouseInstanceManager.unassignSafehouseInstance = function(key)
    local safehouseInstance = safehouseInstances[key]
    assignedSafehouses[key] = nil
end

--- Get safehouse instance information by key
---@param key string
SafehouseInstanceManager.getSafehouseInstanceByKey = function(key)
    return safehouseInstances[key]
end

--- Get the key of the next free safehouse, if any
SafehouseInstanceManager.getNextFreeSafehouseKey = function()
    for key, value in pairs(safehouseInstances) do
        if not assignedSafehouses[key] then
            return key
        end
    end
end

PlayerSafehouseManager = PlayerSafehouseManager or {}

--- Get or assign safehouse and get its key.
---@param player IsoPlayer
PlayerSafehouseManager.getOrAssignSafehouse = function(player)
    if not loaded then
        SafehouseInstanceManager.loadSafehouseInstances(1,1)
    end

    local id = player:getOnlineID() + 1 --todo debug

    local playerSafehouseKey = SafehouseInstanceManager.getPlayerSafehouseKey(id)

    if playerSafehouseKey == nil then
        playerSafehouseKey = SafehouseInstanceManager.getNextFreeSafehouseKey()

        if not playerSafehouseKey then
            warn("PlayerSafehouseManager.getOrAssignSafehouse: No free safehouses found for player.")
            return
        end

        SafehouseInstanceManager.assignSafehouseInstanceToPlayer(playerSafehouseKey, id)
    end

    return playerSafehouseKey
end


--TODO: DEBUG CODE

local function OnLoad()
	SafehouseInstanceManager.loadSafehouseInstances(1,1)
end

Events.OnLoad.Add(OnLoad)