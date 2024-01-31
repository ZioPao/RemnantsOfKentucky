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

    if SafehouseInstanceHandler.IsInSafehouse() == false then return end

    pcall(function()
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
    end)


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

--- Tries to add an item to a crate and returns the used crate
---@param fullType string
---@return IsoObject? crateObj The used crate
function SafehouseInstanceHandler.TryToAddToCrate(fullType)
    local cratesTable = SafehouseInstanceHandler.GetCrates()
    if cratesTable == nil or #cratesTable == 0 then
        debugPrint("Crates are nil or empty!")
        return nil
    end
    local item = InventoryItemFactory.CreateItem(fullType)
    local plNum = getPlayer():getPlayerNum()

    local function GetFirstAvailableCrate()
        for i=1, #cratesTable do
            local crate = cratesTable[i]
            local inv = crate:getContainer()
            local itemContainerGrid = ItemContainerGrid.Create(inv, plNum)

            -- Check if can fit item
            if itemContainerGrid:canAddItem(item) then
                debugPrint("Found available crate => " .. tostring(i))
                return crate
            end
        end


        -- TODO Else throw on the ground
        return nil
    end

    local crate = GetFirstAvailableCrate()
    if crate ~= nil then
        local inv = crate:getContainer()
        debugPrint("Adding " .. fullType .. " to crate")
        inv:AddItem(item)
        inv:addItemOnServer(item)
        inv:setDrawDirty(true)
        inv:setHasBeenLooted(true)
        ISInventoryPage.renderDirty = true
    end

    return crate
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
                    SafehouseInstanceHandler.TryToAddToCrate(element.fullType)
                end
            end
        end

        -- Notify the player
        playerObj:Say(getText("UI_EFT_Say_ReceivedStartedKit"))
    end
    SafehouseInstanceHandler.WaitForSafehouseAndRun(RunGiveStarterKit, {})
end

--* Add Moveable in specific point

function SafehouseInstanceHandler.GetMoveableDeliveryPoint()
    local safehouse = SafehouseInstanceHandler.GetSafehouse()
    if safehouse == nil then
        debugPrint("ERROR: can't find safehouse while searching for delivery point! Maybe too soon?")
        return nil
    end

    local deliveryPoint = PZ_EFT_CONFIG.SafehouseInstanceSettings.safehouseMovDeliveryPoint
    local sq = getCell():getGridSquare(safehouse.x + deliveryPoint.x, safehouse.y + deliveryPoint.y, 0)
    return sq
end

function SafehouseInstanceHandler.IsDeliveryPointClear()
    local sq = SafehouseInstanceHandler.GetMoveableDeliveryPoint()
    if sq == nil then return false end
	for i=1, sq:getObjects():size() do
		local obj = sq:getObjects():get(i-1)
        print(obj:getName())
        local spr = obj:getSprite()

        local props = spr:getProperties()
        if props:Is("IsMoveAble") then
            debugPrint("Found moveable in delivery area, can't put a new one")
            return false
        end
	end

    return true

end

---@param itemObj Moveable
---@return nil
function SafehouseInstanceHandler.TryToPlaceMoveable(itemObj)

    local sq = SafehouseInstanceHandler.GetMoveableDeliveryPoint()
    if sq == nil then return end

    if SafehouseInstanceHandler.IsDeliveryPointClear() then
        local sprite = itemObj:getWorldSprite()

        local props = ISMoveableSpriteProps.new(IsoObject.new(sq, sprite):getSprite())
        props.rawWeight = 10
        props:placeMoveableInternal(sq, itemObj, sprite)
    
    else
        debugPrint("Delivery point is not clear! Can't put items there")
    end


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


---@param sq IsoGridSquare
---@param excludeDeliveryPoint boolean?
---@return boolean
function SafehouseInstanceHandler.IsInStaticArea(sq, excludeDeliveryPoint)

    excludeDeliveryPoint = excludeDeliveryPoint or true

    local isInStaticArea = false
    local safehouse = SafehouseInstanceHandler.GetSafehouse()
    if safehouse then
        local dim = PZ_EFT_CONFIG.SafehouseInstanceSettings.safehouseStaticRoom

        local staticRoomArea = {
            x1 = safehouse.x + dim.x1,
            x2 = safehouse.x + dim.x2,
            y1 = safehouse.y + dim.y1,
            y2 = safehouse.y + dim.y2,
            z1 = 0,
            z2 = 0
        }

        isInStaticArea = PZEFT_UTILS.IsInRectangle({x = sq:getX(), y = sq:getY(), z = sq:getZ() }, staticRoomArea)

        if excludeDeliveryPoint then
            local movDeliverySq = SafehouseInstanceHandler.GetMoveableDeliveryPoint()
            if movDeliverySq and isInStaticArea then
                debugPrint("Checking delivery point")
                isInStaticArea = not(movDeliverySq:getX() == sq:getX() and movDeliverySq:getY() == sq:getY())
            end
        end
    end

    debugPrint(isInStaticArea)

    return isInStaticArea
end

------------------------------------------------------------------------
--* COMMANDS FROM SERVER *--
------------------------------------------------------------------------

require("ROK/DebugTools")
local MODULE = EFT_MODULES.Safehouse

-------------------------

local SafehouseInstanceCommands = {}

function SafehouseInstanceCommands.TeleportToSafehouse(coords)
    local ClientCommon = require("ROK/ClientCommon")
    local ClientState = require("ROK/ClientState")
    ClientCommon.Teleport(coords)
    ClientState.SetIsInRaid(false)
end

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

local function OnSafehouseInstanceCommand(module, command, args)
    if module == MODULE and SafehouseInstanceCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        SafehouseInstanceCommands[command](args)
    end
end


Events.OnServerCommand.Add(OnSafehouseInstanceCommand)

------------------------

return SafehouseInstanceHandler