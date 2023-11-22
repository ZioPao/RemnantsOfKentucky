local GenericUI = require("ROK/UI/GenericUI")
local StoreScrollingListBox = require("ROK/UI/Store/Components/StoreScrollingListBox")
local BuySidePanel = require("ROK/UI/Store/BuySidePanel")
-----------------------

---@class BuyCategory : StoreScrollingListBox
---@field BuySidePanel BuySidePanel
local BuyCategory = StoreScrollingListBox:derive("BuyCategory")

---@param x number
---@param y number
---@param width number
---@param height number
---@param shopPanel any
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

    local fontHgtSmall = GenericUI.SMALL_FONT_HGT
    local entryHgt = fontHgtSmall + 2 * 2
    local buyPanelWidth = self.width / 2 - 20
    local buyPanelHeight = self.height - entryHgt
    local buyPanelX = self.width - buyPanelWidth - 10
    local buyPanelY = entryHgt

    self.BuySidePanel = BuySidePanel:new(buyPanelX, buyPanelY, buyPanelWidth, buyPanelHeight, self.shopPanel)
    self.BuySidePanel:initialise()
    self:addChild(self.BuySidePanel)
end

----------------------------------
---This is run on the the ScrollingBoxList!
---@param x number
---@param y number
function BuyCategory:onMouseDownItems(x, y)
    if #self.items == 0 then return end
    local row = self:rowAt(x, y)

    if row > #self.items then
        row = #self.items
    end
    if row < 1 then
        row = 1
    end

    getSoundManager():playUISound("UISelectListItem")
    self.selected = row
    if self.onmousedown then
        self.onmousedown(self.target, self.items[self.selected].item)
    end

    -- TODO Send data to the BuyQuantityPanel

    self.parent.BuySidePanel:setSelectedItem(self.items[self.selected].item)
end

function BuyCategory:close()
    debugPrint("Closing BuyCategory")
    self.BuySidePanel:removeFromUIManager()
    self.BuySidePanel:close()
    StoreScrollingListBox.close(self)
end

return BuyCategory
