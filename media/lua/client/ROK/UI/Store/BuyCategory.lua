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

    self.buySidePanel = BuySidePanel:new(buyPanelX, buyPanelY, buyPanelWidth, buyPanelHeight, self)
    self.buySidePanel:initialise()
    self:addChild(self.buySidePanel)
end

----------------------------------


function BuyCategory:close()
    debugPrint("Closing BuyCategory")
    self.buySidePanel:removeFromUIManager()
    self.buySidePanel:close()
    StoreScrollingListBox.close(self)
end

return BuyCategory
