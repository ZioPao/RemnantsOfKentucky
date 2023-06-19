-- TODO: If we want to turn this into a framework to support different maps, maybe set these settings through an API to add support to configure through submods
local settings = {
    firstSafehouse = {
        relative = {
            x = 8,
            y = 19,
            z = 0
        }
    },
    safehouseGrid = {
        x = {
            count = 5,
            spacing = 60
        },
        y = {
            count = 5,
            spacing = 60
        }
    }
}

-- TODO PERSIST THIS DATA ON THE SERVER
local safehouseInstances = {} -- key (SafehouseInstanceManager.getSafehouseInstanceID): "x-y-z", value: {x=wx, y=wy, z=wz}
local assignedSafehouses = {} -- key (SafehouseInstanceManager.getSafehouseInstanceID): "x-y-z", value: username

SafehouseInstanceManager = SafehouseInstanceManager or {}

-- DEBUGGING FUNCTIONS --

SafehouseInstanceManager.debug = {}
SafehouseInstanceManager.debug.displaySafehouseInstances = function()
    for key, value in pairs(safehouseInstances) do
        print("Key: " .. key)
    end
end

SafehouseInstanceManager.debug.displayAssignedSafehouseInstances = function()
    for key, value in pairs(assignedSafehouses) do
        print("Key: " .. key)
    end
end

------------------------

--- Get coordinate key string by world X, world Y, worldZ
---@param wx number
---@param wy number
---@param wz number
---@return "wx-wy-wz"
SafehouseInstanceManager.getSafehouseInstanceID = function(wx, wy, wz)
    return wx .. "-" .. wy .. "-" .. wz
end

--- Load safehouse instances using relative cell coordinates.
--- Call this multiple times with different cells if safehouses take up more than one cell
---@param cellX number
---@param cellY number
SafehouseInstanceManager.loadSafehouseInstances = function(cellX, cellY)
    for y = 0, settings.safehouseGrid.y.count - 1 do
        for x = 0, settings.safehouseGrid.x.count - 1 do
            local relativeX = settings.firstSafehouse.relative.x + (x * settings.safehouseGrid.x.spacing)
            local relativeY = settings.firstSafehouse.relative.y + (y * settings.safehouseGrid.y.spacing)
            local relativeZ = settings.firstSafehouse.relative.z

            local wX = (cellX * 300) + relativeX
            local wY = (cellY * 300) + relativeY
            local wZ = relativeZ

            safehouseInstances[SafehouseInstanceManager.getSafehouseInstanceID(wX, wY, wZ)] = {
                x = wX,
                y = wY,
                z = wZ
            }
        end
    end
end

-- TODO Check if the same playerSteamID persists after death/reconnect
--- Assign a safehouse instance by key to player online ID
---@param key string
---@param playerSteamID integer
---@return "wx-wy-wz" Key of assigned safehouse
SafehouseInstanceManager.assignSafehouseInstanceToPlayer = function(key, playerSteamID)
    assignedSafehouses[key] = playerSteamID
    return key
end

--- Get player safehouse by player online ID
---@param playerSteamID integer
---@return "wx-wy-wz" Key of player safehouse
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
---@return {x=0, y=0,z=0} Safehouse Instance
SafehouseInstanceManager.getSafehouseInstanceByKey = function(key)
    return safehouseInstances[key]
end

--- Get the key of the next free safehouse, if any
---@return "wx-wy-wz" Key of next free safehouse
SafehouseInstanceManager.getNextFreeSafehouseKey = function()
    for key, value in pairs(safehouseInstances) do
        if not assignedSafehouses[key] then
            return key
        end
    end
end

--- Get or assign safehouse and get its key.
---@param player IsoPlayer
---@return "wx-wy-wz" Key of assigned safehouse
SafehouseInstanceManager.getOrAssignSafehouse = function(player)
    local id = player:getUsername()

    local playerSafehouseKey = SafehouseInstanceManager.getPlayerSafehouseKey(id)

    if playerSafehouseKey == nil then
        playerSafehouseKey = SafehouseInstanceManager.getNextFreeSafehouseKey()

        if not playerSafehouseKey then
            warn("SafehouseInstanceManager.getOrAssignSafehouse: No free safehouses found for player.")
            return
        end

        SafehouseInstanceManager.assignSafehouseInstanceToPlayer(playerSafehouseKey, id)
    end

    return playerSafehouseKey
end

-- TODO: Check if works well in MP environment
-- TODO: Load persisted data if available

local function OnLoad()
    SafehouseInstanceManager.loadSafehouseInstances(1, 1)
end

Events.OnLoad.Add(OnLoad)
