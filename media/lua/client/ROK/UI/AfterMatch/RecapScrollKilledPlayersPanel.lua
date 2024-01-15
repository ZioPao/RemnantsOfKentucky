-- TODO Wrong base class, we don't want Items


local BaseScrollItemsPanel = require("ROK/UI/BaseComponents/BaseScrollItemsPanel")
----------------
---@class RecapScrollKilledPlayersPanel : BaseScrollItemsPanel
local RecapScrollKilledPlayersPanel = BaseScrollItemsPanel:derive("RecapScrollKilledPlayersPanel")

function RecapScrollKilledPlayersPanel:new(x, y, width, height)
    ---@type RecapScrollKilledPlayersPanel
    local o = BaseScrollItemsPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    ---@cast o RecapScrollKilledPlayersPanel
    RecapScrollKilledPlayersPanel.instance = o
    return o
end
function RecapScrollKilledPlayersPanel:createChildren()
    BaseScrollItemsPanel.createChildren(self)

    self.scrollingListBox:setElementsPerRow(1)
    self.scrollingListBox.doDrawItem = RecapScrollKilledPlayersPanel.DrawItem
    self.scrollingListBox.onMouseDown = nil
end

---@param itemsBox TilesScrollingListBox
---@param y number
---@param item {item : {actualItem : Item, fullType : string}, height : number}
---@param rowElementNumber number
---@return number
function RecapScrollKilledPlayersPanel.DrawItem(itemsBox, y, item, rowElementNumber)
    if y + itemsBox:getYScroll() >= itemsBox.height then return y + item.height end
    if y + item.height + itemsBox:getYScroll() <= 0 then return y + item.height end

    local a = 0.9

    local width = itemsBox:getWidth()/itemsBox.elementsPerRow
    local x = width * rowElementNumber

    local clipY = math.max(0, y + itemsBox:getYScroll())
    local clipY2 = math.min(itemsBox.height, y + itemsBox:getYScroll() + itemsBox.itemheight)

    -- Border of single item
    itemsBox:drawRectBorder(x, y, width, item.height - 1, a, itemsBox.borderColor.r, itemsBox.borderColor.g, itemsBox.borderColor.b)

    -- Items are stored in a table that works as a container, let's unpack them here to make it more readable
    local itemDisplayName = item.item.actualItem:getDisplayName()

    --* ITEM NAME *--
	itemsBox:setStencilRect(x, clipY, width - 1, clipY2 - clipY)
    itemsBox:drawText(itemDisplayName, x + 6, y + 2, 1, 1, 1, a, itemsBox.font)

    --* ITEM COST *--
    local itemData = ShopItemsManager.GetItem(item.item.fullType)

    if itemData == nil then
        itemData = { basePrice = 100, sellMultiplier = 0.5 }
    end

    local price = itemData.basePrice * itemData.sellMultiplier
    local priceStr = "$" .. tostring(price)
    local priceStrY = getTextManager():MeasureStringY(itemsBox.font, priceStr)
    itemsBox:drawText(priceStr, x + 6, y + priceStrY + 2, 1, 1, 1, a, itemsBox.font)
    itemsBox:clearStencilRect()

	itemsBox:repaintStencilRect(x, clipY, width, clipY2 - clipY)

    return y + item.height
end

return RecapScrollKilledPlayersPanel