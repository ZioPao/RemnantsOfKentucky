local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")
---------------

local ClientCommon = {}


---@param playerObj IsoPlayer
---@param sendToCrates boolean
function ClientCommon.GiveStarterKit(playerObj, sendToCrates)
    local function WaitForSafehouse()
        local safehouse = SafehouseInstanceHandler.GetSafehouse()
        if safehouse == nil then return end
        debugPrint("Safehouse is ready! Giving starter kit")
        for i=1, #PZ_EFT_CONFIG.StarterKit do
            ---@type starterKitType
            local element = PZ_EFT_CONFIG.StarterKit[i]
            if sendToCrates then
                for _=1, element.amount do
                    ClientCommon.AddToCrate(element.fullType)
                end
            else
                playerObj:getInventory():AddItems(element.fullType, element.amount)
            end
        end
        Events.OnPlayerUpdate.Remove(WaitForSafehouse)
    end
    Events.OnPlayerUpdate.Add(WaitForSafehouse)
end




---@param fullType string
function ClientCommon.AddToCrate(fullType)
    local cratesTable = SafehouseInstanceHandler.GetCrates()
    if cratesTable == nil then debugPrint("Crates are nil!") return end

    -- Find the first crate which has available space
    local crateCounter = 1
    local switchedToPlayer = false
    local inv = cratesTable[crateCounter]
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


------------------------------------------------------------------------
--* COMMANDS FROM SERVER *--
------------------------------------------------------------------------

local MODULE = EFT_MODULES.Common
local CommonCommands = {}

---Teleport the player
---@param args coords
function CommonCommands.Teleport(args)
    local player = getPlayer()
    player:setX(args.x)
    player:setY(args.y)
    player:setZ(args.z)
    player:setLx(args.x)
    player:setLy(args.y)
    player:setLz(args.z)
end


function CommonCommands.ReceiveStarterKit()
    debugPrint("ReceiveStarterKit")
    ClientCommon.GiveStarterKit(getPlayer(), true)
end

------------------------------------
local function OnCommonCommand(module, command, args)
    if (module == MODULE or module == MODULE) and CommonCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        CommonCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnCommonCommand)



return ClientCommon