if not isServer() then return end

---@alias idPvpInstance string "cellX-cellY"
---@alias pvpInstanceTable {id : idPvpInstance, x : number, y : number, spawnPoints : table, extractionPoints : table}}

require("ROK/DebugTools")
require("ROK/Config")
local pvpInstanceSettings = PZ_EFT_CONFIG.PVPInstanceSettings

-------------------------------------
---@class PvpInstanceManager
local PvpInstanceManager = {}

--- Form an instance id using the cell X and Y
---@param cellX number
---@param cellY number
---@return string "cellX-cellY"
function PvpInstanceManager.getInstanceID(cellX, cellY)
    return cellX .. "-" .. cellY
end

--- Clear existing PVP instance and reload PVP instances
function PvpInstanceManager.Reset()
    ServerData.PVPInstances.SetPvpInstances({})
    ServerData.PVPInstances.SetPvpUsedInstances({})
    ServerData.PVPInstances.SetPvpCurrentInstance({}, false)
    PvpInstanceManager.LoadPvpInstances()
end

--- Refreshes the extractions. Used for when you change some values regarding spawnpoints and extractions.
PvpInstanceManager.refreshPvpInstancesExtractions = function()
    local pvpInstances = ServerData.PVPInstances.GetPvpInstances()
    for _, value in pairs(pvpInstances) do
        local permanentExtractions = PvpInstanceManager.GetPermanentExtractionPoints(value.x, value.y)
        permanentExtractions = permanentExtractions or {}


        local randomExtractions = PvpInstanceManager.GetRandomExtractionPoints(value.x, value.y)
        randomExtractions = randomExtractions or {}

        value.extractionPoints = PZEFT_UTILS.MergeIPairs(randomExtractions, permanentExtractions)
    end
    ServerData.PVPInstances.SetPvpInstances(pvpInstances)
end

--- load PVP instances and add them to the stores
function PvpInstanceManager.LoadPvpInstances()
    local pvpInstances = {}
    local settings = pvpInstanceSettings

    for iY = settings.firstYCellPos, settings.firstYCellPos + (settings.yLength * (settings.yRepeat - 1)) +
        (settings.buffer * (settings.yRepeat - 1)), settings.yLength + 1 do
        for iX = settings.firstXCellPos, settings.firstXCellPos + (settings.xLength * (settings.xRepeat - 1)) +
            (settings.buffer * (settings.xRepeat - 1)), settings.xLength + 1 do

            local id = PvpInstanceManager.getInstanceID(iX, iY)

            local permanentExtractions = PvpInstanceManager.GetPermanentExtractionPoints(iX, iY) or {}
            local randomExtractions = PvpInstanceManager.GetRandomExtractionPoints(iX, iY) or {}

            pvpInstances[id] = {
                id = id,
                x = iX,
                y = iY,
                spawnPoints = PZEFT_UTILS.MapWorldCoordinatesToCell(PZ_EFT_CONFIG.Spawnpoints, iX, iY, {"name"}),
                extractionPoints = PZEFT_UTILS.MergeIPairs(randomExtractions, permanentExtractions)
            }
        end
    end

    ServerData.PVPInstances.SetPvpInstances(pvpInstances)
end

--- Marks old instance as used and Gets new instance
---@return pvpInstanceTable?
function PvpInstanceManager.GetNextInstance()
    local pvpInstances = ServerData.PVPInstances.GetPvpInstances()
    local usedInstances = ServerData.PVPInstances.GetPvpUsedInstances()
    local currentInstance = ServerData.PVPInstances.GetPvpCurrentInstance()
    local changedInstance = false

    for key, value in pairs(pvpInstances) do
        if not usedInstances[key] then
            changedInstance = true
            usedInstances[key] = true
            currentInstance.id = key
            debugPrint("Set to used: " .. tostring(key))
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
function PvpInstanceManager.GetCurrentInstance()
    local currentInstance = ServerData.PVPInstances.GetPvpCurrentInstance()
    if currentInstance == nil then
        debugPrint("GetCurrentInstance returning nil for some reason!")
        return nil
    end
    local pvpInstances = ServerData.PVPInstances.GetPvpInstances()
    return pvpInstances[currentInstance.id]
end

--- Sends the current instance to all players
function PvpInstanceManager.SendCurrentInstance()
    local currentInstance = PvpInstanceManager.GetCurrentInstance()
    if currentInstance == nil then return end   -- TODO add warning
    sendServerCommand("PZEFT-Data", "SetCurrentInstance", currentInstance)
end

--- Clears the players' current instance
function PvpInstanceManager.SendClearCurrentInstance()
    sendServerCommand("PZEFT-Data", "SetCurrentInstance", {})
end

---Consumes a spawnpoint.
---@return {name : string, x : number, y : number, z : number}?
function PvpInstanceManager.PopRandomSpawnPoint()
    debugPrint("Popping random spawn point")
    local currentInstance = PvpInstanceManager.GetCurrentInstance()
    if currentInstance == nil then
        debugPrint("Current instance is nil, can't pop random spawn point")
        return nil
    end
    local size = #currentInstance.spawnPoints

    if size <= 0 then
        debugPrint("No more spawn points left to pop!")
        return nil
    end

    local randIndex = ZombRand(size)
    debugPrint("randIndex for spawnpoint => " .. tostring(randIndex))
    local spawnPoint = currentInstance.spawnPoints[randIndex]
    table.remove(currentInstance.spawnPoints, randIndex)

    if spawnPoint == nil then
        debugPrint("Spawnpoint is nil! Something fucky is going on")
    end
    return spawnPoint
end

--- Gets a random set of extraction points for given an instance
---@param cellX number
---@param cellY number
---@return areaCoords?
function PvpInstanceManager.GetRandomExtractionPoints(cellX, cellY)
    --debugPrint("GetRandomExtractionsPoints")
    --debugPrint("cellX=" .. tostring(cellX))
    --debugPrint("cellY=" .. tostring(cellY))
    --debugPrint("count=" .. tostring(count))

    local amount = #PZ_EFT_CONFIG.RandomExtractionPoints
    local count = 0
    if amount > 0 then
        count = ZombRand(0, amount) + 1
    else
        return {}
    end

    local extractionPoints = PZEFT_UTILS.MapWorldCoordinatesToCell(PZ_EFT_CONFIG.RandomExtractionPoints, cellX, cellY, {"name", "time", "isRandom"})

    if extractionPoints == nil then
        debugPrint("ERROR: no extraction points")
        return nil
    end


    local extractionPointCount = #extractionPoints
    if extractionPointCount <= count then
        --debugPrint("extractionPointCount <= 0")
        --debugPrint(extractionPointCount)
        return extractionPoints
    end

    local activeExtractionPoints = {}

    for i = 1, count do
        local size = #extractionPoints
        local randIndex = ZombRand(size)+1
        local extractionPoint = extractionPoints[randIndex]
        extractionPoint.isRandom = true

        table.insert(activeExtractionPoints, extractionPoint)
        table.remove(extractionPoints, randIndex)
    end

    --PZEFT_UTILS.PrintTable(activeExtractionPoints)

    return activeExtractionPoints
end

--- Gets a permanent set of extraction points for given an instance
---@param cellX number
---@param cellY number
---@return areaCoords?
function PvpInstanceManager.GetPermanentExtractionPoints(cellX, cellY)
    local points = PZEFT_UTILS.MapWorldCoordinatesToCell(PZ_EFT_CONFIG.PermanentExtractionPoints, cellX, cellY, {"name", "time", "isRandom"})
    return points
end

-- function PvpInstanceManager.TeleportPlayersToInstance()
--     debugPrint("Teleporting players")
--     local playersArray = getOnlinePlayers()
--     for i = 0, playersArray:size() - 1 do
--         ---@type IsoPlayer
--         local player = playersArray:get(i)
--         local spawnPoint = PvpInstanceManager.PopRandomSpawnPoint()
--         if not spawnPoint then return end --no more spawnpoints available

--         debugPrint(spawnPoint.name)
--         --debugPrint("Teleporting to instance")
--         -- Teleport the player to their instance
--         local coords = {
--             x = spawnPoint.x,
--             y = spawnPoint.y,
--             z = spawnPoint.z
--         }
--         sendServerCommand(player, EFT_MODULES.Common, "Teleport", coords)

--         -- Set the correct client data
--         sendServerCommand(player, EFT_MODULES.State, "SetClientStateIsInRaid", {value = true})
--     end

--     PvpInstanceManager.SendCurrentInstance()
-- end

local function OnLoad()
    -- TODO We should make this more obvious that the admin needs to start the resetter before starting up the game
    PvpInstanceManager.Reset()
end

Events.OnLoad.Add(OnLoad)
Events.OnServerStarted.Add(OnLoad)


------------------------------------------------------------------------
--* COMMANDS FROM CLIENTS *--
------------------------------------------------------------------------

local MODULE = EFT_MODULES.PvpInstances
local PvpInstanceCommands = {}

---Calculate how many available instances there are and send them back to the clients
function PvpInstanceCommands.GetAmountAvailableInstances()
    local usedInstances = ServerData.PVPInstances.GetPvpUsedInstances()
    local counter = 0
    for _ in pairs(usedInstances) do
        counter = counter + 1
    end

    local amount = 100 - counter
    --print("Amount of instances on the server " .. tostring(amount))
    sendServerCommand(EFT_MODULES.UI, "ReceiveAmountAvailableInstances", {amount = amount})
end

local function OnPvpInstanceCommands(module, command, playerObj, args)
    if module == MODULE and PvpInstanceCommands[command] then
        -- debugPrint("Client Command - " .. MODULE .. "." .. command)
        PvpInstanceCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnPvpInstanceCommands)


-----------------------------

return PvpInstanceManager