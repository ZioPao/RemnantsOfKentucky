-- TODO Save current inventory

-- TODO Compare it with the inventory after match

-- TODO Write it to the RecapPanel

local LootRecapHandler = {}

LootRecapHandler.oldItems = {}
LootRecapHandler.newItems = {}

---@param inv ItemContainer
---@param isBefore boolean
function LootRecapHandler.SaveInventory(inv, isBefore)
    local items = inv:getItems()
    
    local list
    if isBefore then
        LootRecapHandler.oldItems = {}
        list = LootRecapHandler.oldItems
    else
        LootRecapHandler.newItems = {}
        list = LootRecapHandler.oldItems
    end

    for i=0, items:size() - 1 do
        ---@type InventoryItem
        local item = items:get(i)
        local itemID = item:getID()

        list[itemID] = item
    end
    PZEFT_UTILS.PrintTable(list)
    debugPrint("Saved inventory")
end

---@return table<integer, Item>
function LootRecapHandler.CompareWithOldInventory()
    --if #LootRecapHandler.oldItems == 0 and #LootRecapHandler.newItems == 0 then return end

    local actualNewItems = {}
    for k,v in pairs(LootRecapHandler.newItems) do
        if LootRecapHandler.oldItems[k] == nil then
            table.insert(actualNewItems, v)
        end
    end

    return actualNewItems

end


return LootRecapHandler