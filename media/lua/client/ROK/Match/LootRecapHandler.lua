local LootRecapHandler = {}

---@alias LootRecapItemsType table<integer, InventoryItem>

---@type LootRecapItemsType
LootRecapHandler.oldItems = {}
---@type LootRecapItemsType
LootRecapHandler.newItems = {}


function LootRecapHandler.SaveBeforeMatchInventory()
    LootRecapHandler.SaveInventory(true)
end
Events.PZEFT_ClientNowInRaid.Add(LootRecapHandler.SaveBeforeMatchInventory)

function LootRecapHandler.SaveAfterMatchInventory()
    LootRecapHandler.SaveInventory(false)
end
Events.PZEFT_ClientNotInRaidAnymore.Add(LootRecapHandler.SaveAfterMatchInventory)

---@param isStartingRaid boolean
---@private
function LootRecapHandler.SaveInventory(isStartingRaid)
    local mainInv = getPlayer():getInventory()
    local items = mainInv:getItems()

    local list
    if isStartingRaid then
        debugPrint("Saving OLD")
        LootRecapHandler.oldItems = {}
        list = LootRecapHandler.oldItems
    else
        debugPrint("Saving NEW")
        LootRecapHandler.newItems = {}
        list = LootRecapHandler.newItems
    end

    -- Loop
    LootRecapHandler.SaveInventoryLoop(items, list)

    PZEFT_UTILS.PrintTable(list)
    debugPrint("Saved inventory")
end

function LootRecapHandler.SaveInventoryLoop(itemsList, lootList)
    for i=0, itemsList:size() - 1 do
        local item = itemsList:get(i)
        if instanceof(item, "InventoryContainer") then
            LootRecapHandler.SaveInventoryLoop(item:getInventory():getItems(), lootList)
        else
            local itemID = item:getID()
            lootList[itemID] = item
        end
    end
end


function LootRecapHandler.CompareWithOldInventory()
    --if #LootRecapHandler.oldItems == 0 and #LootRecapHandler.newItems == 0 then return end

    local actualNewItems = {}
    for k,v in pairs(LootRecapHandler.newItems) do
        --debugPrint("Checking " .. k)
        if LootRecapHandler.oldItems[k] == nil then
            local fullType = v:getFullType()
            --debugPrint("New item: " .. fullType)
            actualNewItems[k] = {actualItem = v:getScriptItem(), fullType = fullType}
            --table.insert(actualNewItems, v)
        end
    end

    return actualNewItems

    --triggerEvent("PZEFT_LootRecapReady", actualNewItems)
end


return LootRecapHandler