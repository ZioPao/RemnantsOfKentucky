if not isServer() then return end

require("ROK/DebugTools")
require("ROK/Config")
local safehouseSettings = PZ_EFT_CONFIG.SafehouseInstanceSettings
local PlayersManager = require("ROK/PlayersManager")
----------------------

---@class SafehouseInstanceManager
local SafehouseInstanceManager = {}

--- Get coordinate key string by world X, world Y, worldZ
---@param wx number
---@param wy number
---@param wz number
---@return string "wx-wy-wz"
function SafehouseInstanceManager.GetSafehouseInstanceID(wx, wy, wz)
    return wx .. "-" .. wy .. "-" .. wz
end

---Reset all the safehouses
function SafehouseInstanceManager.Reset()
    ServerData.SafehouseInstances.SetSafehouseInstances({})
    ServerData.SafehouseInstances.SetSafehouseAssignedInstances({})
    for i, v in ipairs(PZ_EFT_CONFIG.SafehouseCells) do
        SafehouseInstanceManager.LoadSafehouseInstances(v.x, v.y)
    end

    -- TODO Wipe crates?
end

--- Load safehouse instances using relative cell coordinates.
--- Call this multiple times with different cells if safehouses take up more than one cell
---@param cellX number
---@param cellY number
function SafehouseInstanceManager.LoadSafehouseInstances(cellX, cellY)
    local safehouseInstances = ServerData.SafehouseInstances.GetSafehouseInstances()

    for y = 0, safehouseSettings.safehouseGrid.y.count - 1 do
        for x = 0, safehouseSettings.safehouseGrid.x.count - 1 do
            local relativeX = safehouseSettings.firstSafehouse.relative.x +
                                  (x * safehouseSettings.safehouseGrid.x.spacing)
            local relativeY = safehouseSettings.firstSafehouse.relative.y +
                                  (y * safehouseSettings.safehouseGrid.y.spacing)
            local relativeZ = safehouseSettings.firstSafehouse.relative.z

            local wX = (cellX * 300) + relativeX
            local wY = (cellY * 300) + relativeY
            local wZ = relativeZ

            safehouseInstances[SafehouseInstanceManager.GetSafehouseInstanceID(wX, wY, wZ)] = {
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
---@return string "wx-wy-wz" Key of assigned safehouse
function SafehouseInstanceManager.AssignSafehouseInstanceToPlayer(key, username)
    local assignedSafehouses = ServerData.SafehouseInstances.GetSafehouseAssignedInstances()
    assignedSafehouses[key] = username

    return key
end

--- Get player safehouse key by player username
---@param username string
---@return string? "wx-wy-wz" string of player safehouse
function SafehouseInstanceManager.GetPlayerSafehouseKey(username)
    local assignedSafehouses = ServerData.SafehouseInstances.GetSafehouseAssignedInstances()
    for key, _ in pairs(assignedSafehouses) do
        if assignedSafehouses[key] == username then
            return key
        end
    end

    return nil
end

--- Unassign a safehouse instance 
---@param key string
function SafehouseInstanceManager.UnassignSafehouseInstance(key)
    local assignedSafehouses = ServerData.SafehouseInstances.GetSafehouseAssignedInstances()
    assignedSafehouses[key] = nil
end

--- Get safehouse instance information by key
---@param key string?
---@return table {x=0, y=0,z=0} Safehouse Instance
function SafehouseInstanceManager.GetSafehouseInstanceByKey(key)
    local safehouseInstances = ServerData.SafehouseInstances.GetSafehouseInstances()
    return safehouseInstances[key]
end

--- Get the key of the next free safehouse, if any
---@return string? "wx-wy-wz" string Key of next free safehouse
function SafehouseInstanceManager.GetNextFreeSafehouseKey()
    local safehouseInstances = ServerData.SafehouseInstances.GetSafehouseInstances()
    local assignedSafehouses = ServerData.SafehouseInstances.GetSafehouseAssignedInstances()
    for key, _ in pairs(safehouseInstances) do
        if not assignedSafehouses[key] then
            return key
        end
    end
    return nil
end

--- Get or assign safehouse and get its key.
---@param player IsoPlayer
---@return string? "wx-wy-wz" Key of assigned safehouse
function SafehouseInstanceManager.GetOrAssignSafehouse(player)
    local id = player:getUsername()

    local playerSafehouseKey = SafehouseInstanceManager.GetPlayerSafehouseKey(id)

    if playerSafehouseKey == nil then
        playerSafehouseKey = SafehouseInstanceManager.GetNextFreeSafehouseKey()

        if not playerSafehouseKey then
            debugPrint("SafehouseInstanceManager.getOrAssignSafehouse: No free safehouses found for player.")
            return
        end

        SafehouseInstanceManager.AssignSafehouseInstanceToPlayer(playerSafehouseKey, id)

        -- Clean crates, send starter kit 
        sendServerCommand(player, EFT_MODULES.Safehouse, 'PrepareNewSafehouse', {})

        -- sendServerCommand(player, EFT_MODULES.Safehouse, 'CleanStorage', {})
        
        -- -- New safehouse, new starter kit
        -- sendServerCommand(player, EFT_MODULES.Common, "ReceiveStarterKit", {})
    end

    return playerSafehouseKey
end

---Send a specific player to their safehouse
---@param player IsoPlayer
function SafehouseInstanceManager.SendPlayerToSafehouse(player)
    local playerSafehouseKey = SafehouseInstanceManager.GetOrAssignSafehouse(player)
    local safehouseCoords = SafehouseInstanceManager.GetSafehouseInstanceByKey(playerSafehouseKey)

    sendServerCommand(player, EFT_MODULES.Common, "Teleport", safehouseCoords)
    sendServerCommand(player, EFT_MODULES.State, "SetClientStateIsInRaid", {value = false})
end

---Send all the players to their respective safehouse
function SafehouseInstanceManager.SendAllPlayersToSafehouses()
    local playersArray = getOnlinePlayers()
    for i = 0, playersArray:size() - 1 do
        local player = playersArray:get(i)
        SafehouseInstanceManager.SendPlayerToSafehouse(player)
    end
end

---@param pl IsoPlayer
function SafehouseInstanceManager.ResetPlayerSafehouse(pl)

    debugPrint("ResetSafehouseAllocation")
    local key = SafehouseInstanceManager.GetPlayerSafehouseKey(pl:getUsername())
    sendServerCommand(pl, EFT_MODULES.Safehouse, 'CleanStorage', {})

    if key == nil then error("key is nil while trying to reset safehouse instance") end

    SafehouseInstanceManager.UnassignSafehouseInstance(key)
    local safehouseKey = SafehouseInstanceManager.GetOrAssignSafehouse(pl)
    local safehouseCoords = SafehouseInstanceManager.GetSafehouseInstanceByKey(safehouseKey)
    sendServerCommand(pl, EFT_MODULES.Safehouse, 'SetSafehouse', safehouseCoords)
    sendServerCommand(pl, EFT_MODULES.Common, "Teleport", safehouseCoords)
    sendServerCommand(pl, EFT_MODULES.State, "SetClientStateIsInRaid", {value = false})

end

local function OnLoad()
    for i, v in ipairs(PZ_EFT_CONFIG.SafehouseCells) do
        SafehouseInstanceManager.LoadSafehouseInstances(v.x, v.y)
    end
end

Events.OnLoad.Add(OnLoad)
Events.OnServerStarted.Add(OnLoad)

---------------------------------------------------------
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

------------------------------------------------------------------------
--* COMMANDS FROM SERVER *--
------------------------------------------------------------------------
require("ROK/DebugTools")
local MODULE = EFT_MODULES.Safehouse

-----------------------------

local SafehouseInstanceManagerCommands = {}

--- Sends command to client to set the player's safehouse
---@param playerObj IsoPlayer
---@param args {teleport : boolean, cleanStorage : boolean}
function SafehouseInstanceManagerCommands.RequestSafehouseAllocation(playerObj, args)
    local safehouseKey = SafehouseInstanceManager.GetOrAssignSafehouse(playerObj)
    local safehouseCoords = SafehouseInstanceManager.GetSafehouseInstanceByKey(safehouseKey)

    sendServerCommand(playerObj, MODULE, 'SetSafehouse', safehouseCoords)

    -- TODO Clean Inventory Box here to be sure that it doesn't contain old items.

    if args.teleport then
        debugPrint("Teleporting to instance from request safehouse allocation")
        sendServerCommand(playerObj, EFT_MODULES.Common, "Teleport", safehouseCoords)
    end
end


---Clean current safehouse from a specific player and reassign a new one
---@param args {playerID : number}
function SafehouseInstanceManagerCommands.ResetSafehouseAllocation(_, args)

    local pl = getPlayerByOnlineID(args.playerID)

    debugPrint("ResetSafehouseAllocation")
    local key = SafehouseInstanceManager.GetPlayerSafehouseKey(pl:getUsername())
    sendServerCommand(pl, MODULE, 'CleanStorage', {})

    if key == nil then error("key is nil while trying to reset safehouse instance") end

    SafehouseInstanceManager.UnassignSafehouseInstance(key)
    local safehouseKey = SafehouseInstanceManager.GetOrAssignSafehouse(pl)
    local safehouseCoords = SafehouseInstanceManager.GetSafehouseInstanceByKey(safehouseKey)
    sendServerCommand(pl, MODULE, 'SetSafehouse', safehouseCoords)
    sendServerCommand(pl, EFT_MODULES.Common, "Teleport", safehouseCoords)

end

local OnSafehouseInstanceManagerCommand = function(module, command, playerObj, args)
    if module == MODULE and SafehouseInstanceManagerCommands[command] then
        -- debugPrint("Client Command - " .. MODULE .. "." .. command)
        SafehouseInstanceManagerCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnSafehouseInstanceManagerCommand)

return SafehouseInstanceManager
