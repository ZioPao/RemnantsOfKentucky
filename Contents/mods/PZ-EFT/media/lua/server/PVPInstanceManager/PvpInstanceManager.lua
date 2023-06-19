-- 2x3 cells
-- TODO Add reference to this
-- currentInstance = {id, x, y, spawnPoints = {{x=0,y=0,z=0},{x=0,y=0,z=0}}, extractionPoints = {{x=0,y=0,z=0},{x=0,y=0,z=0}}}
-- pvpInstances[id] = {id = id, x = iX, y = iY, spawnPoints = PvpInstanceManager.getSpawnPointsForInstance(iX, iY)}
-- TODO: If we want to turn this into a framework to support different maps, maybe set these settings through an API to add support to configure through submods
local settings = {
    xLength = 2,
    yLength = 3,

    buffer = 1,

    firstXCellPos = 3,
    firstYCellPos = 2,

    xRepeat = 4,
    yRepeat = 4,

    randomExtractionPointCount = 4
}

-- Spawn points TEST DATA - world coordinates if PVP instance starts at cell 0,0
local spawnPoints = {{
    x = 5,
    y = 5,
    z = 0
}, {
    x = 5,
    y = 58,
    z = 2
}, {
    x = 54,
    y = 56,
    z = 0
}, {
    x = 500,
    y = 550,
    z = 1
}, {
    x = 200,
    y = 300,
    z = 0
}}

local permanentExtractionPoints = {{
    x = 5,
    y = 5,
    z = 0
}, {
    x = 5,
    y = 58,
    z = 2
}}

local randomExtractionPoints = {{
    x = 54,
    y = 56,
    z = 0
}, {
    x = 500,
    y = 550,
    z = 1
}, {
    x = 200,
    y = 300,
    z = 0
}}

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
    return cX .. "-" .. cellY;
end

--- clear existing PVP instance and reload PVP instances
PvpInstanceManager.loadPvpInstancesNew = function()
    if clearInstances then
        pvpInstances = {}
        usedInstances = {}
    end

    PvpInstanceManager.loadPvpInstances();
end

--- load PVP instances and add them to the stores
PvpInstanceManager.loadPvpInstances = function()
    -- iterators
    local iX = settings.firstXCellPos
    local iY = settings.firstYCellPos

    repeat
        repeat
            print("X: " .. iX .. " Y: " .. iY)
            local id = PvpInstanceManager.getInstanceID(iX, iY);
            -- local combinedTable = {table.unpack(table1), table.unpack(table2)}

            local randomExtractions = PvpInstanceManager.getRandomExtractionPoints(iX, iY,
                settings.randomExtractionPointCount);
            local permanentExtractions = PZEFT_UTILS.MapWorldCoordinatesToCell(permanentExtractionPoints, iX, iY);

            pvpInstances[id] = {
                id = id,
                x = iX,
                y = iY,
                spawnPoints = PZEFT_UTILS.MapWorldCoordinatesToCell(spawnPoints, iX, iY),
                extractionPoints = {table.unpack(permanentExtractions), table.unpack(randomExtractions)}
            }

            iX = iX + settings.xLength + 1
        until iX > settings.firstXCellPos + (settings.xLength * (settings.xRepeat - 1)) +
            ((settings.buffer * (settings.xRepeat - 1)))

        iX = settings.firstXCellPos
        iY = iY + settings.yLength + 1
    until iY > settings.firstYCellPos + (settings.yLength * (settings.yRepeat - 1)) +
        ((settings.buffer * (settings.yRepeat - 1)))
end

--- Marks old instance as used and Gets new instance
---@return {id, x, y, spawnPoints = {{x=0,y=0,z=0},{x=0,y=0,z=0}}, extractionPoints = {{x=0,y=0,z=0},{x=0,y=0,z=0}}}
PvpInstanceManager.getNextInstance = function()
    local changedInstance = false;

    for key, value in pairs(pvpInstances) do
        if not usedInstances[key] then
            changedInstance = true;
            currentInstance = value;
            usedInstances[currentInstance.id] = currentInstance
        end
    end

    if not changedInstance then
        warn("No more instances left! Please reset map files.");
        return nil;
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
    local randIndex = ZombRand(size)
    local spawnPoint = currentInstance.spawnPoints[randIndex];
    table.remove(currentInstance.spawnPoints, randIndex)
    return spawnPoint
end

--- Gets a random set of extraction points for given an instance
---@param cX number
---@param cellY number
---@param count number
---@return {{x=5, y=5, z=0}, {x=5, y=5, z=0}}
PvpInstanceManager.getRandomExtractionPoints = function(cX, cellY, count)
    local extractionPoints = PZEFT_UTILS.MapWorldCoordinatesToCell(randomExtractionPoints, cX, cellY)

    local extractionPointCount = #extractionPoints
    if extractionPointCount <= count then
        return randomExtractionPoints
    end

    local activeExtractionPoints = {}

    for i = 1, count do
        local size = #extractionPoints
        local randIndex = ZombRand(size)
        local extractionPoint = extractionPoints[randIndex];
        table.insert(activeExtractionPoints, extractionPoint)
        table.remove(extractionPoints, randIndex)
    end

    return activeExtractionPoints;
end

-- TODO: Check if works well in MP environment
-- TODO: Load persisted data if available

local function OnLoad()
    PvpInstanceManager.loadPvpInstancesNew()
end

Events.OnLoad.Add(OnLoad)