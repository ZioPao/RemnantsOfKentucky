local BaseScrollItemsPanel = require("ROK/UI/Store/Components/BaseScrollItemsPanel")
-----------

---@class BuyScrollItemsPanel : BaseScrollItemsPanel
local BuyScrollItemsPanel = BaseScrollItemsPanel:derive("BuyScrollItemsPanel")

function BuyScrollItemsPanel:new(x, y, width, height)
    local o = BaseScrollItemsPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    BuyScrollItemsPanel.instance = o

    ---@type BuyScrollItemsPanel
    return o
end

local function BuyDoDrawItem(self, y, item, alt)
    if y + self:getYScroll() >= self.height then return y + item.height end
    if y + item.height + self:getYScroll() <= 0 then return y + item.height end

    local a = 0.9

    -- Border of single item
    self:drawRectBorder(0, (y), self:getWidth(), item.height - 1, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)
    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), item.height - 1, 0.3, 0.7, 0.35, 0.15)
    end

    -- Items are stored in a table that works as a container, let's unpack them here to make it more readable
    local itemDisplayName = item.item.actualItem:getDisplayName()
    local itemCost = item.item.basePrice

    --* ITEM NAME *--
    self:drawText(itemDisplayName, 6, y + 2, 1, 1, 1, a, UIFont.Medium)

    --* ITEM COST *--
    self:drawText(itemCost .. " $", self:getWidth() - 100, y + 2, 1, 1, 1, a, UIFont.Medium)

    return y + item.height
end

function BuyScrollItemsPanel:createChildren()
    BaseScrollItemsPanel.createChildren(self)

    self.scrollingListBox.doDrawItem = BuyDoDrawItem
end

function BuyScrollItemsPanel:close()
    BaseScrollItemsPanel.close(self)
end

return BuyScrollItemsPanel
