local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")
---------------

local ClientCommon = {}


---@param playerObj IsoPlayer
---@param sendToCrates boolean
function ClientCommon.GiveStarterKit(playerObj, sendToCrates)
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


return ClientCommon