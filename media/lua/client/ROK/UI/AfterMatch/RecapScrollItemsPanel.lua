local ShopItemsManager = require("ROK/ShopItemsManager")
local BaseScrollItemsPanel = require("ROK/UI/BaseComponents/BaseScrollItemsPanel")
--------------

---@class RecapScrollItemspanel : BaseScrollItemsPanel
local RecapScrollItemsPanel = BaseScrollItemsPanel:derive("RecapScrollItemsPanel")

function RecapScrollItemsPanel:new(x, y, width, height)
    ---@type RecapPanel
    local o = BaseScrollItemsPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    ---@cast o RecapScrollItemsPanel
    RecapPanel.instance = o
    return o
end

function RecapScrollItemsPanel:createChildren()
    BaseScrollItemsPanel.createChildren(self)

    self.scrollingListBox.doDrawItem = RecapScrollItemsPanel.DrawItem
end

function RecapScrollItemsPanel.DrawItem(itemsBox, y, item, alt)
    itemsBox:drawRectBorder(0, (y), itemsBox:getWidth(), itemsBox.itemheight - 1, 0.9, itemsBox.borderColor.r, itemsBox.borderColor.g, itemsBox.borderColor.b)

    local a = 0.9

    --* Item name
    local itemName = item.text
    itemsBox:drawText(itemName, 50, y + 2, 1, 1, 1, a, itemsBox.font)


    --* Amount of same items
    local amount = #item.item
    itemsBox:drawText(tostring(amount), 6, y + 2, 1, 1, 1, a, itemsBox.font)

    --* Price
    local itemFullType = item.item[1]:getFullType()
    local itemData = ShopItemsManager.data[itemFullType]

    if itemData == nil then
        itemData = { basePrice = 100, sellMultiplier = 0.5 }
    end

    local sellPrice = itemData.basePrice * itemData.sellMultiplier
    local sellpriceStr = "$" .. tostring(sellPrice) .. " x " .. tostring(amount)
    local sellPriceX = itemsBox:getWidth() - getTextManager():MeasureStringX(itemsBox.font, sellpriceStr) - 6

    itemsBox:drawText(sellpriceStr, sellPriceX - 5, y + 2, 1, 1, 1, a, itemsBox.font)


    return y + itemsBox.itemheight
end
