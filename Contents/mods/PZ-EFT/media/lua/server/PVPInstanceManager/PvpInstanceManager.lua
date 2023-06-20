-- 2x3 cells
-- TODO Add reference to this
-- currentInstance = {id, x, y, spawnPoints = {{x=0,y=0,z=0},{x=0,y=0,z=0}}, extractionPoints = {{x=0,y=0,z=0},{x=0,y=0,z=0}}}
-- pvpInstances[id] = {id = id, x = iX, y = iY, spawnPoints = PvpInstanceManager.getSpawnPointsForInstance(iX, iY)}

require "PZ_EFT_config"

local pvpInstanceSettings = PZ_EFT_CONFIG.PVPInstanceSettings

-- TODO PERSIST THIS DATA ON THE SERVER
local pvpInstances = {} -- key (PvpInstanceManager.getInstanceID): "x-y", value: {id="x-y", x=cx, y=cy, spawnPoints={{x,y,z}, {x,y,z}}, extractionPoints={{x,y,z}}}
local usedInstances = {} -- reference pvpInstances
local currentInstance = nil -- reference pvpInstance.value

PvpInstanceManager = PvpInstanceManager or {}

-- DEBUGGING FUNCTIONS --

PvpInstanceManager.debug = PvpInstanceManager.debug or {}
PvpInstanceManager.debug.getPvpInstances = function()
    for key, value in pairs(pvpInstances) do
        print("Key: " .. key)
    end
end

PvpInstanceManager.debug.getUsedPvpInstances = function()
    for key, value in pairs(usedInstances) do
        print("Key: " .. key)
    end
end

PvpInstanceManager.debug.getCurrentInstance = function()
    if currentInstance then
        print(currentInstance.id)
    else
        print(nil)
    end
end

------------------------

--- Form an instance id using the cell X and Y
---@param cellX number
---@param cellY number
---@return "cellX-cellY"
PvpInstanceManager.getInstanceID = function(cellX, cellY)
    return cellX .. "-" .. cellY
end

--- clear existing PVP instance and reload PVP instances
PvpInstanceManager.loadPvpInstancesNew = function()
    if clearInstances then
        pvpInstances = {}
        usedInstances = {}
    end

    PvpInstanceManager.loadPvpInstances()
end

--- load PVP instances and add them to the stores
PvpInstanceManager.loadPvpInstances = function()
    -- iterators
    local iX = pvpInstanceSettings.firstXCellPos
    local iY = pvpInstanceSettings.firstYCellPos

    repeat
        repeat
            local id = PvpInstanceManager.getInstanceID(iX, iY)
        
            local randomExtractions = PvpInstanceManager.getRandomExtractionPoints(iX, iY,
            pvpInstanceSettings.randomExtractionPointCount)
            local permanentExtractions = PZEFT_UTILS.MapWorldCoordinatesToCell(PZ_EFT_CONFIG.PermanentExtractionPoints, iX, iY, {"time", "radius"})

            for _, value in ipairs(permanentExtractions) do
                value.extractionSquares = PZEFT_UTILS.getSurroundingGridCoordinates(value, value.radius)
            end
            
            pvpInstances[id] = {
                id = id,
                x = iX,
                y = iY,
                spawnPoints = PZEFT_UTILS.MapWorldCoordinatesToCell(PZ_EFT_CONFIG.Spawnpoints, iX, iY),
                extractionPoints = {table.unpack(permanentExtractions), table.unpack(randomExtractions)}
            }

            iX = iX + pvpInstanceSettings.xLength + 1
        until iX > pvpInstanceSettings.firstXCellPos + (pvpInstanceSettings.xLength * (pvpInstanceSettings.xRepeat - 1)) +
            ((pvpInstanceSettings.buffer * (pvpInstanceSettings.xRepeat - 1)))

        iX = pvpInstanceSettings.firstXCellPos
        iY = iY + pvpInstanceSettings.yLength + 1
    until iY > pvpInstanceSettings.firstYCellPos + (pvpInstanceSettings.yLength * (pvpInstanceSettings.yRepeat - 1)) +
        ((pvpInstanceSettings.buffer * (pvpInstanceSettings.yRepeat - 1)))
end

--- Marks old instance as used and Gets new instance
---@return {id, x, y, spawnPoints = {{x=0,y=0,z=0},{x=0,y=0,z=0}}, extractionPoints = {{x=0,y=0,z=0},{x=0,y=0,z=0}}}
PvpInstanceManager.getNextInstance = function()
    local changedInstance = false

    for key, value in pairs(pvpInstances) do
        if not usedInstances[key] then
            changedInstance = true
            currentInstance = value
            usedInstances[currentInstance.id] = currentInstance
        end
    end

    if not changedInstance then
        warn("No more instances left! Please reset map files.")
        return nil
    end

    return currentInstance
end

--- Get the current active instance
---@return {id, x, y, spawnPoints = {{x=0,y=0,z=0},{x=0,y=0,z=0}}, extractionPoints = {{x=0,y=0,z=0},{x=0,y=0,z=0}}}
PvpInstanceManager.getCurrentInstance = function()
    return currentInstance
end

---Consumes a spawnpoint.
---@return {x=5, y=5, z=0}
PvpInstanceManager.popRandomSpawnPoint = function()
    local size = #currentInstance.spawnPoints

    if size <= 0 then
        warn("No more spawn points left to pop!")
        return nil
    end

    local randIndex = ZombRand(size)
    local spawnPoint = currentInstance.spawnPoints[randIndex]
    table.remove(currentInstance.spawnPoints, randIndex)
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
        local randIndex = ZombRand(size)
        local extractionPoint = extractionPoints[randIndex]

        extractionPoint.extractionSquares = PZEFT_UTILS.getSurroundingGridCoordinates(extractionPoint, extractionPoint.radius)

        table.insert(activeExtractionPoints, extractionPoint)
        table.remove(extractionPoints, randIndex)
    end

    return activeExtractionPoints
end

-- TODO: Check if works well in MP environment
-- TODO: Load persisted data if available

local function OnLoad()
    PvpInstanceManager.loadPvpInstancesNew()
end

Events.OnLoad.Add(OnLoad)