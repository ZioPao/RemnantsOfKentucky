require("ROK/DebugTools")
--------------------------

---@class SafehouseInstanceHandler
local SafehouseInstanceHandler = {}

function SafehouseInstanceHandler.RefreshSafehouseAllocation()
    sendClientCommand(EFT_MODULES.Safehouse, "RequestSafehouseAllocation", {teleport = false})
end

--- This check is on the client side. Maybe somehow move to the server but that might be costly.
---@return boolean
function SafehouseInstanceHandler.IsInSafehouse()
    --if isDebugEnabled() then return end
    --print("Running isInSafehouse")
    if not ClientState.isInRaid then
        --print("Player is not in a raid, running check for safehouse")
        local md = PZEFT_UTILS.GetPlayerModData()

        if not md.safehouse then
            return false
        end

        local sq = getPlayer():getSquare()

        if not sq then
            return false
        end

        if sq:getZ() ~= 0 then
            return false
        end

        local dimensions = PZ_EFT_CONFIG.SafehouseInstanceSettings.dimensions
        if getPlayer():isOutside() or not PZEFT_UTILS.IsPointWithinDimensions(md.safehouse.x, md.safehouse.y, dimensions.n,
                dimensions.s, dimensions.e, dimensions.w, sq:getX(), sq:getY()) then
            sendClientCommand("PZEFT-Safehouse", "RequestSafehouseAllocation", {
                teleport = true
            })
        end

        return true
    end

    return false
end

---Return safehouse coords for the current player
---@return coords?
function SafehouseInstanceHandler.GetSafehouse()
    local md = PZEFT_UTILS.GetPlayerModData()
    if not md.safehouse then
        return nil
    end

    return md.safehouse
end

---@return table<integer, ItemContainer>?
function SafehouseInstanceHandler.GetCrates()
    local cratesTable = {}
    local safehouse = SafehouseInstanceHandler.GetSafehouse()
    if safehouse == nil then
        error("ERROR: can't find safehouse!")
        return
    end
    for _, group in pairs(PZ_EFT_CONFIG.SafehouseInstanceSettings.safehouseStorage) do
        local sq = getCell():getGridSquare(safehouse.x + group.x, safehouse.y + group.y, 0)
        if sq == nil then
            error("ERROR: Square not found while searching for crates")
            break
        end
        local objects = sq:getObjects()
        for i = 0, objects:size() - 1 do
            local obj = objects:get(i)
            local container = obj:getContainer()
            if container then table.insert(cratesTable, container) end
        end
    end

    debugPrint("Found " .. #cratesTable .. " crates")

    return cratesTable
end

---Wipes all the items in the crates of a player safehouse
function SafehouseInstanceHandler.WipeCrates()
    for _, group in pairs(PZ_EFT_CONFIG.SafehouseInstanceSettings.safehouseStorage) do
        local sq = getCell():getGridSquare(group.x, group.y, 0)
        local objects = sq:getObjects()
        local inventoryContainer
        for i = 1, objects:size() do
            if instanceof(objects:get(i), "InventoryItem") then
                inventoryContainer = objects:get(i):getContainer()
                if inventoryContainer then
                    inventoryContainer:clear()
                else
                    error("Crate found, but no InventoryContainer")
                end
            end
        end
    end
end

--- On player initialise, request safehouse allocation of player from server
---@param player IsoPlayer
function SafehouseInstanceHandler.OnPlayerInit(player)
    debugPrint("Running onplayerinit")
    if player and player == getPlayer() then
        local md = PZEFT_UTILS.GetPlayerModData()
        if not md.safehouse then
            -- Request safe house allocation, which in turn will teleport the player to the assigned safehouse
            sendClientCommand(EFT_MODULES.Safehouse, "RequestSafehouseAllocation", {
                teleport = true
            })
        end
    end

    -- TODO This probably needs to be moved somewhere else
    Events.OnPlayerUpdate.Remove(SafehouseInstanceHandler.OnPlayerInit)
end

Events.OnPlayerUpdate.Add(SafehouseInstanceHandler.OnPlayerInit)

------------------------------------------------------------------------
--* COMMANDS FROM SERVER *--
------------------------------------------------------------------------

require("ROK/DebugTools")
local MODULE = EFT_MODULES.Safehouse

-------------------------

local SafehouseInstanceCommands = {}

--- When client recieves SetSafehouse Server Command
--- Update mod data of player with recieved safehouse data
---@param safehouseCoords coords {x=0, y=0,z=0} Safehouse Instance
function SafehouseInstanceCommands.SetSafehouse(safehouseCoords)
    local md = PZEFT_UTILS.GetPlayerModData()
    md.safehouse = safehouseCoords
end

---Receive a Clean Storage from an Admin
function SafehouseInstanceCommands.CleanStorage()
    -- TODO Test this
    for _, group in pairs(PZ_EFT_CONFIG.SafehouseInstanceSettings.safehouseStorage) do
        local sq = getCell():getGridSquare(group.x, group.y, 0)
        local objects = sq:getObjects()
        local inventoryContainer
        for i=1, objects:size() do
            if instanceof(objects:get(i), "InventoryItem") then
                inventoryContainer = objects:get(i):getContainer()
                if inventoryContainer then
                    inventoryContainer:clear()
                else
                    error("Crate found, but no InventoryContainer")
                end
            end
        end
    end

end

------------------------

local OnSafehouseInstanceCommand = function(module, command, args)
    if module == MODULE and SafehouseInstanceCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        SafehouseInstanceCommands[command](args)
    end
end


Events.OnServerCommand.Add(OnSafehouseInstanceCommand)

------------------------

return SafehouseInstanceHandler