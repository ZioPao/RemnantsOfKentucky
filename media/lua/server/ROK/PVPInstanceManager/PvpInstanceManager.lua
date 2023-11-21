if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then return end

---@alias idPvpInstance string "cellX-cellY"
---@alias pvpInstanceTable {id : idPvpInstance, x : number, y : number, spawnPoints : table, extractionPoints : table}}

require("ROK/DebugTools")
require("ROK/Config")
local TeleportManager = require("ROK/TeleportManager")
local pvpInstanceSettings = PZ_EFT_CONFIG.PVPInstanceSettings

-------------------------------------
---@class PvpInstanceManager
PvpInstanceManager = {}

--- Form an instance id using the cell X and Y
---@param cellX number
---@param cellY number
---@return string "cellX-cellY"
PvpInstanceManager.getInstanceID = function(cellX, cellY)
    return cellX .. "-" .. cellY
end

--- Clear existing PVP instance and reload PVP instances
PvpInstanceManager.reset = function()
    ServerData.PVPInstances.SetPvpInstances({})
    ServerData.PVPInstances.SetPvpUsedInstances({})
    ServerData.PVPInstances.SetPvpCurrentInstance({}, true)
    PvpInstanceManager.loadPvpInstances()
end

--- Refreshes the extractions. Used for when you change some values regarding spawnpoints and extractions.
PvpInstanceManager.refreshPvpInstancesExtractions = function()
    local pvpInstances = ServerData.PVPInstances.GetPvpInstances()
    for _, value in pairs(pvpInstances) do
        local permanentExtractions = PvpInstanceManager.getPermanentExtractionPoints(value.x, value.y)
        permanentExtractions = permanentExtractions or {}
        local randomExtractions = PvpInstanceManager.getRandomExtractionPoints(value.x, value.y, pvpInstanceSettings.randomExtractionPointCount)
        randomExtractions = randomExtractions or {}

        value.extractionPoints = PZEFT_UTILS.MergeIPairs(randomExtractions, permanentExtractions)
    end
    ServerData.PVPInstances.SetPvpInstances(pvpInstances)
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
            permanentExtractions = permanentExtractions or {}
            local randomExtractions = PvpInstanceManager.getRandomExtractionPoints(iX, iY, pvpInstanceSettings.randomExtractionPointCount)
            randomExtractions = randomExtractions or {}

            pvpInstances[id] = {
                id = id,
                x = iX,
                y = iY,
                spawnPoints = PZEFT_UTILS.MapWorldCoordinatesToCell(PZ_EFT_CONFIG.Spawnpoints, iX, iY, {"name"}),
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
---@return pvpInstanceTable?
PvpInstanceManager.getNextInstance = function()
    local pvpInstances = ServerData.PVPInstances.GetPvpInstances()
    local usedInstances = ServerData.PVPInstances.GetPvpUsedInstances()
    local currentInstance = ServerData.PVPInstances.GetPvpCurrentInstance()
    local changedInstance = false

    for key, value in pairs(pvpInstances) do
        if not usedInstances[key] then
            changedInstance = true
            usedInstances[key] = true
            currentInstance.id = key
            break
        end
    end

    if not changedInstance then
        debugPrint("No more instances left! Please reset map files.")
        return nil
    end

    ServerData.PVPInstances.SetPvpUsedInstances(usedInstances)
    ServerData.PVPInstances.SetPvpCurrentInstance(currentInstance, true)
    return pvpInstances[currentInstance.id]
end

--- Get the current active instance
---@return pvpInstanceTable?
PvpInstanceManager.getCurrentInstance = function()
    local currentInstance = ServerData.PVPInstances.GetPvpCurrentInstance()
    local pvpInstances = ServerData.PVPInstances.GetPvpInstances()
    return pvpInstances[currentInstance.id]
end

--- Sends the current instance to all players
PvpInstanceManager.sendCurrentInstance = function()
    local currentInstance = PvpInstanceManager.getCurrentInstance()
    if currentInstance == nil then return end   -- TODO add warning
    sendServerCommand("PZEFT", "SetCurrentInstance", currentInstance)
end

--- Clears the players' current instance
PvpInstanceManager.sendClearCurrentInstance = function()
    sendServerCommand("PZEFT", "SetCurrentInstance", {})
end

---Consumes a spawnpoint.
---@return coords
PvpInstanceManager.popRandomSpawnPoint = function()
    local currentInstance = PvpInstanceManager.getCurrentInstance()
    local size = #currentInstance.spawnPoints

    if size <= 0 then
        debugPrint("No more spawn points left to pop!")
        return nil
    end

    local randIndex = ZombRand(size)
    local spawnPoint = currentInstance.spawnPoints[randIndex]
    table.remove(currentInstance.spawnPoints, randIndex)

    ServerData.PVPInstances.SetPvpCurrentInstance(currentInstance, true)

    return spawnPoint
end

--- Gets a random set of extraction points for given an instance
---@param cellX number
---@param cellY number
---@param count number
---@return areaCoords?
PvpInstanceManager.getRandomExtractionPoints = function(cellX, cellY, count)
    if not count then
        return {}
    end
    
    local extractionPoints = PZEFT_UTILS.MapWorldCoordinatesToCell(PZ_EFT_CONFIG.RandomExtractionPoints, cellX, cellY, {"name", "time"})

    if extractionPoints == nil then
        debugPrint("ERROR: no extraction points")
        return nil
    end


    local extractionPointCount = #extractionPoints
    if extractionPointCount <= count then
        return extractionPoints
    end

    local activeExtractionPoints = {}

    for i = 1, count do
        local size = #extractionPoints
        local randIndex = ZombRand(size)+1
        local extractionPoint = extractionPoints[randIndex]

        table.insert(activeExtractionPoints, extractionPoint)
        table.remove(extractionPoints, randIndex)
    end

    return activeExtractionPoints
end

--- Gets a permanent set of extraction points for given an instance
---@param cellX number
---@param cellY number
---@return areaCoords?
PvpInstanceManager.getPermanentExtractionPoints = function(cellX, cellY)
    local points = PZEFT_UTILS.MapWorldCoordinatesToCell(PZ_EFT_CONFIG.PermanentExtractionPoints, cellX, cellY, {"name", "time"})
    return points
end

PvpInstanceManager.teleportPlayersToInstance = function()
    --local currentInstance = PvpInstanceManager.getCurrentInstance()

    --debugPrint("Teleport Players to Instance")
    local temp = getOnlinePlayers()
    for i = 0, temp:size() - 1 do

        ---@type IsoPlayer
        local player = temp:get(i)
        local spawnPoint = PvpInstanceManager.popRandomSpawnPoint()
        if not spawnPoint then return end --no more spawnpoints available

        --debugPrint("Teleporting to instance")
        TeleportManager.Teleport(player, spawnPoint.x, spawnPoint.y, spawnPoint.z)

        -- Client Data
        sendServerCommand(player, "PZEFT", "SetClientStateIsInRaid", {value = true})
    end

    PvpInstanceManager.sendCurrentInstance()
end


----

PvpInstanceManager.getAmountUsedInstances = function()
    --debugPrint("Get amount used instances")
    local usedInstances = ServerData.PVPInstances.GetPvpUsedInstances()
    if usedInstances ~= nil then
        --debugPrint("Used instances is not nil")
        --0print(PZEFT_UTILS.PrintTable(usedInstances))

        -- TODO For some fucking reason I can't use # even if it's a normal table.
        local amount = 0
        for key, _ in pairs(usedInstances) do
            if key and key ~= "" then
                amount = amount + 1
            end
        end

        -- TODO This is probably wrong, find a better way
        if amount > 0 then amount = amount / 3 end
        return amount

    else
        return 0
    end
end


local function OnLoad()
    PvpInstanceManager.loadPvpInstances()
end

Events.OnLoad.Add(OnLoad)
Events.OnServerStarted.Add(OnLoad)