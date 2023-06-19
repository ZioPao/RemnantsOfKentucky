-- 2x3 cells
local settings = {
    xLength = 2,
    yLength = 3,

    buffer = 1,

    firstXCellPos = 3,
    firstYCellPos = 2,

    xRepeat = 4,
    yRepeat = 4
}

--Spawn points - world coordinates if PVP instance starts at cell 0,0
local spawnPoints = {
    {x=5, y=5, z=0},
    {x=5, y=58, z=2},
    {x=54, y=56, z=0},
    {x=500, y=550, z=1},
    {x=200, y=300, z=0},
}

--TODO PERSIST THIS DATA ON THE SERVER
local pvpInstances = {} -- key (PvpInstanceManager.getInstanceID): "x-y", value: {id="x-y", x=cx, y=cy, spawnPoints=[{x,y,z}, {x,y,z}]}
local usedInstances = {} -- reference pvpInstances
local currentInstance = nil -- reference pvpInstance.value

PvpInstanceManager = PvpInstanceManager or {}

PvpInstanceManager.getInstanceID = function(cX, cY)
    return cX .. "-" .. cY;
end

PvpInstanceManager.loadPvpInstancesNew = function()
    if clearInstances then
        pvpInstances = {}
        usedInstances = {}
    end

    PvpInstanceManager.loadPvpInstances();
end

PvpInstanceManager.loadPvpInstances = function(clearInstances)
    --iterators
    local iX = settings.firstXCellPos
    local iY = settings.firstYCellPos

    repeat
        repeat
            print("X: " .. iX .. " Y: " .. iY)
            local id = PvpInstanceManager.getInstanceID(iX, iY);
            pvpInstances[id] = {id = id, x = iX, y = iY, spawnPoints = PvpInstanceManager.getSpawnPointsForInstance(iX, iY)}

            iX = iX + settings.xLength + 1
        until iX > settings.firstXCellPos + (settings.xLength * (settings.xRepeat - 1)) +
            ((settings.buffer * (settings.xRepeat - 1)))

        iX = settings.firstXCellPos
        iY = iY + settings.yLength + 1
    until iY > settings.firstYCellPos + (settings.yLength * (settings.yRepeat - 1)) +
        ((settings.buffer * (settings.yRepeat - 1)))
end

--- Marks old instance as used and Gets new instance
---@param if any
PvpInstanceManager.getNextInstance = function()
    if currentInstance then
        usedInstances[currentInstance.id] = currentInstance
    end

    currentInstance = nil;

    for key, value in pairs(pvpInstances) do
        if not usedInstances[key] then
            currentInstance = value;
        end
    end
    
    if not currentInstance then
        warn("No more instances left! Please reset map files.");
    end

    return currentInstance
end

PvpInstanceManager.getCurrentInstance = function()
    return currentInstance
end

PvpInstanceManager.getSpawnPointsForInstance = function(cX,cY)
    local mappedSpawnPoints = {}
    for index, point in ipairs(spawnPoints) do
        local wX = cX * 300
        local wY = cY * 300
        
        table.insert(mappedSpawnPoints, {x = wX + point.x, y = wY + point.y, z = point.z});
    end

    return mappedSpawnPoints;
end
