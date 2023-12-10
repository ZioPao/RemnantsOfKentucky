require("ROK/DebugTools")
local BlackScreen = require("ROK/UI/BeforeMatch/BlackScreen")
local ClientState = require("ROK/ClientState")
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
    if ClientState.isStartingMatch or ClientState.isAdminMode then return end

    -- TODO Check Admin Mode
    if not SafehouseInstanceHandler.IsInSafehouse() then
        BlackScreen.Open()
        sendClientCommand(EFT_MODULES.Safehouse, "RequestSafehouseAllocation", {
            teleport = true
        })
    else
        BlackScreen.Close()

        -- -- TODO Not working
        -- for _,v in ipairs(PZ_EFT_CONFIG.SafehouseCells)do
        --     zpopClearZombies(v.x,v.y)
        -- end
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


---Wait until the safehouse is ready and run a specific function
---@param funcToRun function
---@param args {} args for the function
function SafehouseInstanceHandler.WaitForSafehouseAndRun(funcToRun, args)
    local function WaitAndRun()
        local crates = SafehouseInstanceHandler.GetCrates()
        if crates == nil or #crates ~= PZ_EFT_CONFIG.SafehouseInstanceSettings.cratesAmount then return end

        debugPrint("Running function, safehouse is valid!")
        funcToRun(unpack(args))

        Events.OnPlayerUpdate.Remove(WaitAndRun)
    end

    Events.OnPlayerUpdate.Add(WaitAndRun)
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

--* Crates handling
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
    local function RunWipe()
        local cratesTable = SafehouseInstanceHandler.GetCrates()
        if cratesTable == nil then debugPrint("No crates to wipe") return end

        for i=1, #cratesTable do
            local crate = cratesTable[i]
            crate:clear()
        end
    end
    SafehouseInstanceHandler.WaitForSafehouseAndRun(RunWipe, {})
end

---@param fullType string
function SafehouseInstanceHandler.AddToCrate(fullType)
    local cratesTable = SafehouseInstanceHandler.GetCrates()
    if cratesTable == nil or #cratesTable == 0 then debugPrint("Crates are nil or empty!") return end

    -- Find the first crate which has available space
    local crateCounter = 1
    local switchedToPlayer = false
    local inv = cratesTable[crateCounter]

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
                inv = cratesTable[crateCounter]
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