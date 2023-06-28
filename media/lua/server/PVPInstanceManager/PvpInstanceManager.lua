if (not isServer()) and not (not isServer() and not isClient()) then return end

require "PZ_EFT_debugtools"
require "PZ_EFT_config"

local pvpInstanceSettings = PZ_EFT_CONFIG.PVPInstanceSettings

PvpInstanceManager = PvpInstanceManager or {}

--- Form an instance id using the cell X and Y
---@param cellX number
---@param cellY number
---@return "cellX-cellY"
PvpInstanceManager.getInstanceID = function(cellX, cellY)
    return cellX .. "-" .. cellY
end

--- clear existing PVP instance and reload PVP instances
PvpInstanceManager.reset = function(clearInstances)
    ServerData.PVPInstances.SetPvpInstances({})
    ServerData.PVPInstances.SetPvpUsedInstances({})
    ServerData.PVPInstances.SetPvpCurrentInstance({})
    PvpInstanceManager.loadPvpInstances()
end

--- load PVP instances and add them to the stores
PvpInstanceManager.loadPvpInstances = function()
    local pvpInstances = ServerData.PVPInstances.GetPvpInstances()
    -- iterators
    local iX = pvpInstanceSettings.firstXCellPos
    local iY = pvpInstanceSettings.firstYCellPos

    repeat
        repeat
            local id = PvpInstanceManager.getInstanceID(iX, iY)

            local permanentExtractions = PvpInstanceManager.getPermanentExtractionPoints(iX, iY)
            local randomExtractions = PvpInstanceManager.getRandomExtractionPoints(iX, iY, pvpInstanceSettings.randomExtractionPointCount)

            pvpInstances[id] = {
                id = id,
                x = iX,
                y = iY,
                spawnPoints = PZEFT_UTILS.MapWorldCoordinatesToCell(PZ_EFT_CONFIG.Spawnpoints, iX, iY),
                extractionPoints = PZEFT_UTILS.MergeIPairs(randomExtractions, permanentExtractions)
            }

            iX = iX + pvpInstanceSettings.xLength + 1
        until iX > pvpInstanceSettings.firstXCellPos + (pvpInstanceSettings.xLength * (pvpInstanceSettings.xRepeat - 1)) +
            ((pvpInstanceSettings.buffer * (pvpInstanceSettings.xRepeat - 1)))

        iX = pvpInstanceSettings.firstXCellPos
        iY = iY + pvpInstanceSettings.yLength + 1
    until iY > pvpInstanceSettings.firstYCellPos + (pvpInstanceSettings.yLength * (pvpInstanceSettings.yRepeat - 1)) +
        ((pvpInstanceSettings.buffer * (pvpInstanceSettings.yRepeat - 1)))

        
    ServerData.PVPInstances.SetPvpInstances(pvpInstances)
end

--- Marks old instance as used and Gets new instance
---@return {id, x, y, spawnPoints = {{x=0,y=0,z=0},{x=0,y=0,z=0}}, extractionPoints = {{x=0,y=0,z=0},{x=0,y=0,z=0}}}
PvpInstanceManager.getNextInstance = function()
    local pvpInstances = ServerData.PVPInstances.GetPvpInstances()
    local usedInstances = ServerData.PVPInstances.GetPvpUsedInstances()
    local currentInstance = ServerData.PVPInstances.GetPvpCurrentInstance()
    local changedInstance = false

    for key, value in pairs(pvpInstances) do
        if not usedInstances[key] then
            changedInstance = true
            usedInstances[currentInstance.id] = true
            currentInstance = value
            break;
        end
    end

    if not changedInstance then
        print("No more instances left! Please reset map files.")
        return nil
    end

    ServerData.PVPInstances.SetPvpUsedInstances(usedInstances)
    ServerData.PVPInstances.SetPvpCurrentInstance(currentInstance)
    return currentInstance
end

--- Get the current active instance
---@return {id, x, y, spawnPoints = {{x=0,y=0,z=0},{x=0,y=0,z=0}}, extractionPoints = {{x=0,y=0,z=0},{x=0,y=0,z=0}}}
PvpInstanceManager.getCurrentInstance = function()
    return ServerData.PVPInstances.GetPvpCurrentInstance()
end

---Consumes a spawnpoint.
---@return {x=5, y=5, z=0}
PvpInstanceManager.popRandomSpawnPoint = function()
    local currentInstance = ServerData.PVPInstances.GetPvpCurrentInstance()
    local size = #currentInstance.spawnPoints

    if size <= 0 then
        print("No more spawn points left to pop!")
        return nil
    end

    local randIndex = ZombRand(size)
    local spawnPoint = currentInstance.spawnPoints[randIndex]
    table.remove(currentInstance.spawnPoints, randIndex)

    ServerData.PVPInstances.SetPvpCurrentInstance(currentInstance)

    return spawnPoint
end

--- Gets a random set of extraction points for given an instance
---@param cellX number
---@param cellY number
---@param count number
---@return {{x=5, y=5, z=0, time=0, radius=1, extractionSquares={{x=1,y=1,z=1}}}
PvpInstanceManager.getRandomExtractionPoints = function(cellX, cellY, count)
    local extractionPoints = PZEFT_UTILS.MapWorldCoordinatesToCell(PZ_EFT_CONFIG.RandomExtractionPoints, cellX, cellY, {"time", "radius"})

    local extractionPointCount = #extractionPoints
    if extractionPointCount <= count then
        return extractionPoints
    end

    local activeExtractionPoints = {}

    for i = 1, count do
        local size = #extractionPoints
        local randIndex = ZombRand(size)+1
        local extractionPoint = extractionPoints[randIndex]

        extractionPoint.extractionSquares = PZEFT_UTILS.getSurroundingGridCoordinates(extractionPoint, extractionPoint.radius)

        table.insert(activeExtractionPoints, extractionPoint)
        table.remove(extractionPoints, randIndex)
    end

    return activeExtractionPoints
end

--- Gets a permanent set of extraction points for given an instance
---@param cellX number
---@param cellY number
---@return {{x=5, y=5, z=0, time=0, radius=1, extractionSquares={{x=1,y=1,z=1}}}
PvpInstanceManager.getPermanentExtractionPoints = function(cellX, cellY)
    local points = PZEFT_UTILS.MapWorldCoordinatesToCell(PZ_EFT_CONFIG.PermanentExtractionPoints, cellX, cellY, {"time", "radius"})

    for _, value in ipairs(points) do
        value.extractionSquares = PZEFT_UTILS.getSurroundingGridCoordinates(value, value.radius)
    end

    return points
end

local function OnLoad()
    PvpInstanceManager.loadPvpInstances()
end

Events.OnLoad.Add(OnLoad)
Events.OnServerStarted.Add(OnLoad)