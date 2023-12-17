-- TODO Save current inventory

-- TODO Compare it with the inventory after match

-- TODO Write it to the RecapPanel

local LootRecapHandler = {}

LootRecapHandler.oldItems = {}
LootRecapHandler.newItems = {}


function LootRecapHandler.SaveBeforeMatchInventory()
    LootRecapHandler.SaveInventory(true)
end
Events.PZEFT_OnMatchStart.Add(LootRecapHandler.SaveBeforeMatchInventory)

function LootRecapHandler.SaveAfterMatchInventory()
    LootRecapHandler.SaveInventory(false)
end
Events.PZEFT_OnMatchEnd.Add(LootRecapHandler.SaveAfterMatchInventory)

---@param isStartingRaid boolean
---@private
function LootRecapHandler.SaveInventory(isStartingRaid)
    local inv = getPlayer():getInventory()
    local items = inv:getItems()

    local list
    if isStartingRaid then
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