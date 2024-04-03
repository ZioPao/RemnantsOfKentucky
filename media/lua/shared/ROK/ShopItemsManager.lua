--* COMMON CLASS TO FETCH DATA FROM GLOBAL MOD DATA EFT_ModDataKeys.SHOP_ITEMS *--
---@alias shopItemElement {fullType : string, tag : string, basePrice : number, multiplier : number, sellMultiplier : number, quantity : number?}



---@class ShopItemsManager
local ShopItemsManager = {}


--* SERVER ONLY
--- Add shop item
---@param fullType itemFullType
---@param tag string
---@param basePrice integer
function ShopItemsManager.AddItem(fullType, tag, basePrice)
    ---@type shopItemsTable
    local data = ModData.get(EFT_ModDataKeys.SHOP_ITEMS)

    data.items = data.items or {}
    data.items[fullType] = { fullType = fullType, tag = tag, basePrice = basePrice, multiplier = 1, sellMultiplier = 0.5 }

    data.tags = data.tags or {}
    data.tags[tag] = data.tags[tag] or {}
    data.tags[tag][fullType] = true
end

function ShopItemsManager.SetTagToItem(fullType, tag)
    ---@type shopItemsTable
    local data = ModData.get(EFT_ModDataKeys.SHOP_ITEMS)

    data.items = data.items or {}
    data.items[fullType].tag = tag

    data.tags = data.tags or {}
    data.tags[tag] = data.tags[tag] or {}
    data.tags[tag][fullType] = true
end


--* COMMON
---@param fullType string
---@return shopItemElement
function ShopItemsManager.GetItem(fullType)
    local data = ModData.get(EFT_ModDataKeys.SHOP_ITEMS)

    ---@type shopItemElement
    local itemData = data.items[fullType]
    return itemData
end


---------------------------------------------
--* Sell Stuff

---@alias sellData table<integer, {itemData : shopItemElement, quantity : number, quality : number}>

--- ItemsList is coming from the ScrollingListBox, we need to keep track of quality stuff so that's why we need groups of every single item
---@param itemsList table<integer, {item : table<integer, InventoryItem>}>
---@return sellData
function ShopItemsManager.StructureSellData(itemsList)
    -- Cycle through the items and structure them in the correct way
    local structuredData = {}
    for i = 1, #itemsList do
        local quality = 1
        local genericItem = itemsList[i].item[1]
        local fullType = genericItem:getFullType()
        local quantity = #itemsList[i].item

        local isDrainable = ScriptManager.instance:isDrainableItemType(fullType)
        local isClothing = instanceof(genericItem, "IsoClothing")

        if isDrainable or isClothing then
            quality = 0
            for j = 1, #itemsList[i].item do
                local item = itemsList[i].item[j]

                if isDrainable then
                    quality = quality + item:getUsedDelta()
                elseif isClothing then
                    quality = quality + item:getCondition()
                end
            end
            quality = quality / quantity -- mean
            debugPrint(quality)
        end

        local itemData = ShopItemsManager.GetItem(fullType)
        table.insert(structuredData, { itemData = itemData, quantity = quantity, quality = quality })
    end

    return structuredData
end



return ShopItemsManager
