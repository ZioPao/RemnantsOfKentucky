require("ROK/DebugTools")
local BlackScreen = require("ROK/UI/BeforeMatch/BlackScreen")
local ClientState = require("ROK/ClientState")
local ClientCommon = require("ROK/ClientCommon")
--------------------------

---@class SafehouseInstanceHandler
local SafehouseInstanceHandler = {}

function SafehouseInstanceHandler.RefreshSafehouseAllocation()
    sendClientCommand(EFT_MODULES.Safehouse, "RequestSafehouseAllocation", {teleport = false})
end

--- Check if the player is in their safehouse
---@return boolean
function SafehouseInstanceHandler.IsInSafehouse()
    local md = PZEFT_UTILS.GetPlayerModData()
    if not md.safehouse then return false end

    local sq = getPlayer():getSquare()
    if not sq or sq:getZ() ~= 0 then return false end

    local dim = PZ_EFT_CONFIG.SafehouseInstanceSettings.dimensions
    if getPlayer():isOutside() or not PZEFT_UTILS.IsPointWithinDimensions(md.safehouse.x, md.safehouse.y, dim.n, dim.s, dim.e, dim.w, sq:getX(), sq:getY()) then return false end

    return true
end

---Used in a Loop, check if the player is in the safehouse and if not teleports them forcefully. Opens a Black screen if they're not in the safehouse too
function SafehouseInstanceHandler.HandlePlayerInSafehouse()

    -- Prevent this from running if we're starting a match
    if ClientState.isStartingMatch then return end


    if not SafehouseInstanceHandler.IsInSafehouse() then
        BlackScreen.Open()
        sendClientCommand(EFT_MODULES.Safehouse, "RequestSafehouseAllocation", {
            teleport = true
        })
    else
        BlackScreen.Close()
        for _,v in ipairs(PZ_EFT_CONFIG.SafehouseCells)do
            zpopClearZombies(v.x,v.y)
        end
    end
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
        debugPrint("ERROR: can't find safehouse! Maybe too soon?")
        return
    end
    for _, group in pairs(PZ_EFT_CONFIG.SafehouseInstanceSettings.safehouseStorage) do
        local sq = getCell():getGridSquare(safehouse.x + group.x, safehouse.y + group.y, 0)
        if sq == nil then
            debugPrint("ERROR: Square not found while searching for crate. Maybe too soon?")
            break
        end
        local objects = sq:getObjects()
        for i = 0, objects:size() - 1 do
            local obj = objects:get(i)
            local container = obj:getContainer()
            if container then table.insert(cratesTable, container) end
        end
    end

    --debugPrint("Found " .. #cratesTable .. " crates")

    return cratesTable
end

---Wipes all the items in the crates of the current player safehouse. Run from the admin panel
function SafehouseInstanceHandler.WipeCrates()
    ClientCommon.WaitForSafehouseAndRun(function()
        local cratesTable = SafehouseInstanceHandler.GetCrates()
        if cratesTable == nil then debugPrint("No crates to wipe") return end

        for i=1, #cratesTable do
            local crate = cratesTable[i]
            crate:clear()
        end
    end, {})
end

--* Events handling

--- On player initialise, request safehouse allocation of player from server
---@param player IsoPlayer
function SafehouseInstanceHandler.OnPlayerInit(player)
    debugPrint("Running safehouse instance handler onplayerinit")
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

---Receive a Clean Storage from the server
function SafehouseInstanceCommands.CleanStorage()
    SafehouseInstanceHandler.WipeCrates()
end

---Wipes the crates of the new instanced safehouse and give the starter kit to the player
function SafehouseInstanceCommands.PrepareNewSafehouse()
    SafehouseInstanceHandler.WipeCrates()
    ClientCommon.GiveStarterKit(getPlayer(), true)
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