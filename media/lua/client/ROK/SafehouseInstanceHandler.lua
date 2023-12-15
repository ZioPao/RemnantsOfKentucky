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
---@return IsoObject crateObj The used crate
function SafehouseInstanceHandler.AddToCrate(fullType)
    local cratesTable = SafehouseInstanceHandler.GetCrates()
    if cratesTable == nil or #cratesTable == 0 then debugPrint("Crates are nil or empty!") return end


    -- Find the first crate which has available space
    local crateCounter = 1
    local switchedToPlayer = false
    local crateObj = cratesTable[crateCounter]
    local inv = crateObj:getContainer()

    crateObj:setHighlighted(true)
    crateObj:setHighlightColor(1,1,0, 0.5)

    -- TODO Workaround for play test!
    if fullType == "ROK.InstaHeal" then
        local ClientCommon = require("ROK/ClientCommon")
        ClientCommon.InstaHeal()
    else
        local item = InventoryItemFactory.CreateItem(fullType)
        ---@diagnostic disable-next-line: param-type-mismatch
        if not inv:hasRoomFor(getPlayer(), item) and not switchedToPlayer then
            debugPrint("Switching to next crate")
            crateCounter = crateCounter + 1
            if crateCounter < #cratesTable then
                crateObj = cratesTable[crateCounter]
                inv = crateObj:getContainer()
            else
                debugPrint("No more space in the crates, switching to dropping stuff in the player's inventory")
                inv = getPlayer():getInventory()
                switchedToPlayer = true
            end
        end
        inv:addItemOnServer(item)
        inv:addItem(item)
        inv:setDrawDirty(true)
        ISInventoryPage.renderDirty = true
    end


    -- TODO Return used crates
    return crateObj

end


--* Starter kit 

---@param playerObj IsoPlayer
---@param sendToCrates boolean
function SafehouseInstanceHandler.GiveStarterKit(playerObj, sendToCrates)
    function RunGiveStarterKit()
        for i=1, #PZ_EFT_CONFIG.StarterKit do
            ---@type starterKitType
            local element = PZ_EFT_CONFIG.StarterKit[i]
            if sendToCrates then
                for _=1, element.amount do
                    SafehouseInstanceHandler.AddToCrate(element.fullType)
                end
            else
                playerObj:getInventory():AddItems(element.fullType, element.amount)
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