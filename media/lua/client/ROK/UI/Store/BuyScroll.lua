local StoreScrollingListBox = require("ROK/UI/Store/Components/StoreScrollingListBox")
local BuySidePanel = require("ROK/UI/Store/BuySidePanel")
-----------------------

local BuyCategory = StoreScrollingListBox:derive("BuyCategory")

---@param x number
---@param y number
---@param width number
---@param height number
---@param shopPanel MainShopPanel
---@return BuyCategory
function BuyCategory:new(x, y, width, height, shopPanel)
    local o = StoreScrollingListBox:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.shopPanel = shopPanel
    BuyCategory.instance = o

    ---@type BuyCategory
    return o
end

function BuyCategory:createChildren()
    StoreScrollingListBox.createChildren(self)

    self.items.doDrawItem = self.doDrawItem

    local buyPanelWidth = self.width / 2 - 20
    local buyPanelX = self.width - buyPanelWidth - 10

    self.buySidePanel = BuySidePanel:new(buyPanelX, self.panelYPadding, buyPanelWidth, self.panelHeight, self)
    self.buySidePanel:initialise()
    self:addChild(self.buySidePanel)
end


function BuyCategory:doDrawItem(y, item, alt)
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

----------------------------------

function BuyCategory:close()
    StoreScrollingListBox.close(self)
end

return BuyCategory
