local StoreScrollItemsPanel = require("ROK/UI/Store/Components/StoreScrollItemsPanel")
local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
-----------

---@class BuyScrollItemsPanel : StoreScrollItemsPanel
local BuyScrollItemsPanel = StoreScrollItemsPanel:derive("BuyScrollItemsPanel")

function BuyScrollItemsPanel:new(x, y, width, height)
    local o = StoreScrollItemsPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    BuyScrollItemsPanel.instance = o

    ---@type BuyScrollItemsPanel
    return o
end

---@param y any
---@param item any
---@param rowElementNumber number
---@return number
local function BuyDoDrawItem(self, y, item, rowElementNumber)
    -- Multi item same line
    if y + self:getYScroll() >= self.height then return y + item.height end
    if y + item.height + self:getYScroll() <= 0 then return y + item.height end

    local a = 0.9

    local width = self:getWidth()/self.elementsPerRow
    local x = width * rowElementNumber

    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    -- Border of single item
    self:drawRectBorder(x, y, width, item.height - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    if self.selected == item.index then
        self:drawRect(x, y, width, item.height - 1, 0.3, 0.7, 0.35, 0.15)
    end

    -- Items are stored in a table that works as a container, let's unpack them here to make it more readable
    local itemDisplayName = item.item.actualItem:getDisplayName()
    local itemCost = item.item.basePrice

    --* ITEM NAME *--
	self:setStencilRect(x, clipY, width - 1, clipY2 - clipY)
    self:drawText(itemDisplayName, x + 6, y + 2, 1, 1, 1, a, self.font)

    --* ITEM COST *--
    local priceStr = "$" .. GenericUI.FormatCurrency(itemCost)
    local priceStrY = getTextManager():MeasureStringY(self.font, priceStr)
    self:drawText(priceStr, x + 6, y + priceStrY + 2, 1, 1, 1, a, self.font)
    self:clearStencilRect()


	self:repaintStencilRect(x, clipY, width, clipY2 - clipY)

    return y + item.height
end

function BuyScrollItemsPanel:createChildren()
    StoreScrollItemsPanel.createChildren(self)

    self.scrollingListBox.doDrawItem = BuyDoDrawItem
end

function BuyScrollItemsPanel:close()
    StoreScrollItemsPanel.close(self)
end

return BuyScrollItemsPanel
