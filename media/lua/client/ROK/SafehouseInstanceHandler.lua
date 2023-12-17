---@class SafehouseInstanceHandler
local SafehouseInstanceHandler = {}

--* Crates Handling

---@return table<integer, IsoObject>?
function SafehouseInstanceHandler.GetCrates()
    local cratesTable = {}
    local safehouse = SafehouseInstanceHandler.GetSafehouse()
    if safehouse == nil then
        debugPrint("ERROR: can't find safehouse! Maybe too soon?")
        return nil
    end
    for _, group in pairs(PZ_EFT_CONFIG.SafehouseInstanceSettings.safehouseStorage) do
        local sq = getCell():getGridSquare(safehouse.x + group.x, safehouse.y + group.y, 0)
        if sq == nil then
            debugPrint("ERROR: Square not found while searching for crate. Maybe too soon?")
            break
        end
        local objects = sq:getObjects()
        for i = 0, objects:size() - 1 do

            ---@type IsoObject
            local obj = objects:get(i)
            if obj:getContainer() ~= nil then table.insert(cratesTable, obj) end
        end
    end

    --debugPrint("Found " .. #cratesTable .. " crates")

    return cratesTable
end

---Wipes all the items in the crates of the current player safehouse. Run from the admin panel
function SafehouseInstanceHandler.WipeCrates()
    local function RunWipe()
        local cratesTable = SafehouseInstanceHandler.GetCrates()
        if cratesTable == nil then debugPrint("No crates to wipe") return end

        for i=1, #cratesTable do
            local crate = cratesTable[i]
            crate:getContainer():clear()
        end
    end
    SafehouseInstanceHandler.WaitForSafehouseAndRun(RunWipe, {})
end


---@param fullType string
---@return IsoObject? crateObj The used crate
function SafehouseInstanceHandler.AddToCrate(fullType)
    local cratesTable = SafehouseInstanceHandler.GetCrates()
    if cratesTable == nil or #cratesTable == 0 then
        debugPrint("Crates are nil or empty!")
        return nil
    end

    -- Find the first crate which has available space
    local crateCounter = 1
    local switchedToPlayer = false
    local crate = cratesTable[crateCounter]
    local inv = crate:getContainer()

    local plNum = getPlayer():getPlayerNum()
    local itemContainerGrid = ItemContainerGrid.Create(inv, plNum)


    local item = InventoryItemFactory.CreateItem(fullType)
    if not itemContainerGrid:canAddItem(item) and not switchedToPlayer then

        while crateCounter < #cratesTable do
            crate = cratesTable[crateCounter]
            itemContainerGrid = ItemContainerGrid.Create(inv, plNum)
            if itemContainerGrid:canAddItem(item) then
                debugPrint("Switching to next crate")
                break
            end

            crateCounter = crateCounter + 1
        end

        if not itemContainerGrid:canAddItem(item) then
            inv = getPlayer():getInventory()
            switchedToPlayer = true
            itemContainerGrid = ItemContainerGrid.Create(inv, plNum)
            debugPrint("Switched to player")
        end
    end
    if itemContainerGrid:canAddItem(item) then
        debugPrint("Adding " .. fullType .. " to crate nr " .. crateCounter)
        inv:AddItem(item)
        inv:addItemOnServer(item)
        inv:setDrawDirty(true)
        inv:setHasBeenLooted(true)
        ISInventoryPage.renderDirty = true

        -- Return used crates
        return crate
    end
    return nil
end

function SafehouseInstanceHandler.AddToCrateOrdered(fullType, index, x, y, isRotated)
    local cratesTable = SafehouseInstanceHandler.GetCrates()
    if cratesTable == nil or #cratesTable == 0 then debugPrint("Crates are nil or empty!") return nil end
    local crateObj = cratesTable[index]
    local inv = crateObj:getContainer()
    local grid = ItemContainerGrid.Create(inv, getPlayer():getPlayerNum())
    local item = InventoryItemFactory.CreateItem(fullType)

    if grid:canAddItem(item) then
        debugPrint("Adding " .. fullType .. " to crate " .. tostring(index) .. " at X=" .. tostring(x) .. ", Y=" .. tostring(y))
        inv:addItemOnServer(item)
        inv:AddItem(item)
        inv:setDrawDirty(true)
        inv:setHasBeenLooted(true)

        grid:insertItem(item, x, y, 1, isRotated)
    
        ISInventoryPage.renderDirty = true
    end
end


--* Starter kit 

---@param playerObj IsoPlayer
---@param ordered boolean
function SafehouseInstanceHandler.GiveStarterKit(playerObj, ordered)

    -- 10 x 10 with tetris inventory

    function RunGiveStarterKit()
        for i=1, #PZ_EFT_CONFIG.StarterKit do
            ---@type starterKitType
            local element = PZ_EFT_CONFIG.StarterKit[i]

            if ordered then

                local loc = PZ_EFT_CONFIG.StarterKitLocations[element.fullType]
                for j=1, element.amount do
                    SafehouseInstanceHandler.AddToCrateOrdered(element.fullType, loc.crateIndex, loc[j].x, loc[j].y, loc[j].isRotated)
                end
            else
                for _=1, element.amount do
                    SafehouseInstanceHandler.AddToCrate(element.fullType)
                end
            end
        end

        -- Notify the player
        playerObj:Say(getText("UI_EFT_Say_ReceivedStartedKit"))
    end
    SafehouseInstanceHandler.WaitForSafehouseAndRun(RunGiveStarterKit, {})
end


--* Safehouse Checks

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

---Return safehouse coords for the current player
---@return coords?
function SafehouseInstanceHandler.GetSafehouse()
    local md = PZEFT_UTILS.GetPlayerModData()
    if not md.safehouse then
        return nil
    end

    return md.safehouse
end

--* Utilities

---Wait until the safehouse is ready and run a specific function
---@param funcToRun function
---@param args {} args for the function
function SafehouseInstanceHandler.WaitForSafehouseAndRun(funcToRun, args)
    local function WaitAndRun()
        local crates = SafehouseInstanceHandler.GetCrates()
        if crates == nil or #crates ~= PZ_EFT_CONFIG.SafehouseInstanceSettings.cratesAmount then return end

        debugPrint("Running function, safehouse is valid!")
        ---@diagnostic disable-next-line: deprecated
        funcToRun(unpack(args))

        Events.OnPlayerUpdate.Remove(WaitAndRun)
    end

    Events.OnPlayerUpdate.Add(WaitAndRun)
end


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
    SafehouseInstanceHandler.GiveStarterKit(getPlayer(), true)
end

function SafehouseInstanceCommands.ReceiveStarterKit()
    debugPrint("ReceiveStarterKit")
    SafehouseInstanceHandler.GiveStarterKit(getPlayer(), true)
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