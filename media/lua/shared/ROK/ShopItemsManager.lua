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



return ShopItemsManager
