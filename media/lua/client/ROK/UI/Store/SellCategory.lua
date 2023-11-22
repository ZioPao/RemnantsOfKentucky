local StoreScrollingListBox = require("ROK/UI/Store/Components/StoreScrollingListBox")
local GenericUI = require("ROK/UI/GenericUI")
local SellSidePanel = require("ROK/UI/Store/SellSidePanel")
-----------------------

---@class SellCategory : StoreScrollingListBox
local SellCategory = StoreScrollingListBox:derive("SellCategory")

---@param x number
---@param y number
---@param width number
---@param height number
---@param shopPanel any
---@return SellCategory
function SellCategory:new(x, y, width, height, shopPanel)
    local o = StoreScrollingListBox:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.shopPanel = shopPanel
    SellCategory.instance = o

    ---@cast o SellCategory
    return o
end

function SellCategory:createChildren()
    StoreScrollingListBox.createChildren(self)

    local fontHgtSmall = GenericUI.SMALL_FONT_HGT
    local entryHgt = fontHgtSmall + 2 * 2

    local sellPanelWidth = self.width / 2 - 20
    local sellPanelHeight = self.height - entryHgt
    local sellPanelX = self.width - sellPanelWidth - 10
    local sellPanelY = entryHgt

    self.SellSidePanel = SellSidePanel:new(sellPanelX, sellPanelY, sellPanelWidth, sellPanelHeight, self.shopPanel)
    self.SellSidePanel:initialise()
    self:addChild(self.SellSidePanel)
end

----------------------------------

function SellCategory:close()
    self.SellSidePanel:removeFromUIManager()
    self.SellSidePanel:close()
    StoreScrollingListBox.close(self)
end

return SellCategory
