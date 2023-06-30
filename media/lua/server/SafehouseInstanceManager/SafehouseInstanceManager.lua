if (not isServer()) and not (not isServer() and not isClient()) then return end

require "PZ_EFT_debugtools"
require "PZ_EFT_config"

local safehouseSettings = PZ_EFT_CONFIG.SafehouseInstanceSettings

SafehouseInstanceManager = SafehouseInstanceManager or {}

-- DEBUGGING FUNCTIONS --

SafehouseInstanceManager.debug = {}
SafehouseInstanceManager.debug.displaySafehouseInstances = function()
    local safehouseInstances = ServerData.SafehouseInstances.GetSafehouseInstances()
    for key, value in pairs(safehouseInstances) do
        debugPrint("Key: " .. key)
    end
end

SafehouseInstanceManager.debug.displayAssignedSafehouseInstances = function()
    local assignedSafehouses = ServerData.SafehouseInstances.GetSafehouseAssignedInstances()
    for key, value in pairs(assignedSafehouses) do
        debugPrint("Key: " .. key)
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

SafehouseInstanceManager.reset = function()
    ServerData.SafehouseInstances.SetSafehouseInstances({})
    ServerData.SafehouseInstances.SetSafehouseAssignedInstances({})
    for i,v in ipairs(PZ_EFT_CONFIG.SafehouseCells) do
        SafehouseInstanceManager.loadSafehouseInstances(v.x,v.y)
    end
end

--- Load safehouse instances using relative cell coordinates.
--- Call this multiple times with different cells if safehouses take up more than one cell
---@param cellX number
---@param cellY number
SafehouseInstanceManager.loadSafehouseInstances = function(cellX, cellY)
    local safehouseInstances = ServerData.SafehouseInstances.GetSafehouseInstances()

    for y = 0, safehouseSettings.safehouseGrid.y.count - 1 do
        for x = 0, safehouseSettings.safehouseGrid.x.count - 1 do
            local relativeX = safehouseSettings.firstSafehouse.relative.x + (x * safehouseSettings.safehouseGrid.x.spacing)
            local relativeY = safehouseSettings.firstSafehouse.relative.y + (y * safehouseSettings.safehouseGrid.y.spacing)
            local relativeZ = safehouseSettings.firstSafehouse.relative.z

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

    ServerData.SafehouseInstances.SetSafehouseInstances(safehouseInstances)
end

--- Assign a safehouse instance by key to player online ID
---@param key string
---@param username string
---@return "wx-wy-wz" Key of assigned safehouse
SafehouseInstanceManager.assignSafehouseInstanceToPlayer = function(key, username)
    local assignedSafehouses = ServerData.SafehouseInstances.GetSafehouseAssignedInstances()
    assignedSafehouses[key] = username
    return key
end

--- Get player safehouse key by player username
---@param username string
---@return "wx-wy-wz" Key of player safehouse
SafehouseInstanceManager.getPlayerSafehouseKey = function(username)
    local assignedSafehouses = ServerData.SafehouseInstances.GetSafehouseAssignedInstances()
    for key, value in pairs(assignedSafehouses) do
        if assignedSafehouses[key] == username then
            return key
        end
    end
end

--- Unassign a safehouse instance 
---@param key string
SafehouseInstanceManager.unassignSafehouseInstance = function(key)
    local assignedSafehouses = ServerData.SafehouseInstances.GetSafehouseAssignedInstances()
    assignedSafehouses[key] = nil
end

--- Get safehouse instance information by key
---@param key string
---@return {x=0, y=0,z=0} Safehouse Instance
SafehouseInstanceManager.getSafehouseInstanceByKey = function(key)
    local safehouseInstances = ServerData.SafehouseInstances.GetSafehouseInstances()
    return safehouseInstances[key]
end

--- Get the key of the next free safehouse, if any
---@return "wx-wy-wz" Key of next free safehouse
SafehouseInstanceManager.getNextFreeSafehouseKey = function()
    local safehouseInstances = ServerData.SafehouseInstances.GetSafehouseInstances()
    local assignedSafehouses = ServerData.SafehouseInstances.GetSafehouseAssignedInstances()
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
            print("SafehouseInstanceManager.getOrAssignSafehouse: No free safehouses found for player.")
            return
        end

        SafehouseInstanceManager.assignSafehouseInstanceToPlayer(playerSafehouseKey, id)
    end

    return playerSafehouseKey
end

local function OnLoad()
    for i,v in ipairs(PZ_EFT_CONFIG.SafehouseCells) do
        SafehouseInstanceManager.loadSafehouseInstances(v.x,v.y)
    end
end

Events.OnLoad.Add(OnLoad)
Events.OnServerStarted.Add(OnLoad)