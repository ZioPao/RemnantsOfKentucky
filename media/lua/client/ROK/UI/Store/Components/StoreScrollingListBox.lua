--local BuyQuantityPanel = require("ROK/UI/Store/BuyQuantityPanel")
local GenericUI = require("ROK/UI/GenericUI")
-----------------------

---@class StoreScrollingListBox : ISPanelJoypad
local StoreScrollingListBox = ISPanelJoypad:derive("StoreScrollingListBox")

function StoreScrollingListBox:new(x, y, width, height, shopPanel)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.shopPanel = shopPanel
    StoreScrollingListBox.instance = o
    return o
end

-- Can't override initialise for some reason
function StoreScrollingListBox:initalise()
    ISPanelJoypad.initialise(self)
end

---@param itemsTable any
function StoreScrollingListBox:initialiseList(itemsTable)
    if itemsTable == nil then return end

    for tableName, data in pairs(itemsTable) do
        data.actualItem = getScriptManager():getItem(tableName)
        self.items:addItem(tableName, data)
    end

    -- Select first item in the list automatically
    if #itemsTable > 1 then
        self.items.selected = 1
        local selectedItem = self.items.items[self.items.selected].item
        self.buyPanel:setSelectedItem(selectedItem)
    end
end

function StoreScrollingListBox:createChildren()
    local fontHgtSmall = GenericUI.SMALL_FONT_HGT
    local entryHgt = fontHgtSmall + 2 * 2

    self.items = ISScrollingListBox:new(10, entryHgt, self.width / 2, self.height - entryHgt)
    self.items:initialise()
    self.items:instantiate()
    self.items:setAnchorRight(false) -- resize in update()
    self.items:setAnchorBottom(true)
    self.items.itemHeight = 2 + GenericUI.MEDIUM_FONT_HGT + 32 + 4
    self.items.selected = 0
    self.items.doDrawItem = StoreScrollingListBox.doDrawItem
    self.items.onMouseDown = StoreScrollingListBox.onMouseDownItems
    self.items.joypadParent = self
    self.items.drawBorder = true
    self:addChild(self.items)

    self.items.SMALL_FONT_HGT = GenericUI.SMALL_FONT_HGT
    self.items.MEDIUM_FONT_HGT = GenericUI.MEDIUM_FONT_HGT

    -- local buyPanelWidth = self.width / 2 - 20
    -- local buyPanelHeight = self.height - entryHgt
    -- local buyPanelX = self.width - buyPanelWidth - 10
    -- local buyPanelY = entryHgt

    -- self.buyPanel = BuyQuantityPanel:new(buyPanelX, buyPanelY, buyPanelWidth, buyPanelHeight, self.shopPanel)
    -- self.buyPanel:initialise()
    -- self:addChild(self.buyPanel)
end

----------------------------------
function StoreScrollingListBox:update()
    if not self.parent:getIsVisible() then return end
end

function StoreScrollingListBox:prerender()
    ISPanelJoypad.prerender(self)
    self.items.backgroundColor.a = 0.8
    self.items.doDrawItem = StoreScrollingListBox.doDrawItem
end

function StoreScrollingListBox:doDrawItem(y, item, alt)
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

-- ---This is run on the the ScrollingBoxList!
-- ---@param x number
-- ---@param y number
-- function StoreScrollingListBox:onMouseDownItems(x, y)
--     if #self.items == 0 then return end
--     local row = self:rowAt(x, y)

--     if row > #self.items then
--         row = #self.items
--     end
--     if row < 1 then
--         row = 1
--     end

--     getSoundManager():playUISound("UISelectListItem")
--     self.selected = row
--     if self.onmousedown then
--         self.onmousedown(self.target, self.items[self.selected].item)
--     end

--     -- TODO Send data to the BuyQuantityPanel

--     self.parent.buyPanel:setSelectedItem(self.items[self.selected].item)
-- end

function StoreScrollingListBox:close()
    --debugPrint("Closing StoreCategory")
    --self.buyPanel:removeFromUIManager()
    --self.buyPanel:close()
    ISPanelJoypad.close(self)
end

return StoreScrollingListBox
