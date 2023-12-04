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
    self.panelYPadding = GenericUI.SMALL_FONT_HGT + 2 * 2
    self.panelHeight = self.height - self.panelYPadding - 10

    self.items = ISScrollingListBox:new(10, self.panelYPadding, self.width / 2, self.panelHeight)
    self.items:initialise()
    self.items:instantiate()
    self.items:setAnchorRight(false) -- resize in update()
    self.items:setAnchorBottom(true)
    self.items.itemHeight = 2 + GenericUI.MEDIUM_FONT_HGT + 32 + 4
    self.items.selected = 0
    self.items.onMouseDown = StoreScrollingListBox.onMouseDownItems
    self.items.joypadParent = self
    self.items.drawBorder = true
    self:addChild(self.items)

    self.items.SMALL_FONT_HGT = GenericUI.SMALL_FONT_HGT
    self.items.MEDIUM_FONT_HGT = GenericUI.MEDIUM_FONT_HGT
end

----------------------------------
function StoreScrollingListBox:update()
    --debugPrint("StoreScrollingListBox update")
    if not self.parent:getIsVisible() then return end
end

function StoreScrollingListBox:prerender()
    ISPanelJoypad.prerender(self)

end

---This is run on the the ScrollingBoxList!
---@param x number
---@param y number
function StoreScrollingListBox:onMouseDownItems(x, y)
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

    self.parent:setSelectedItem(self.items[self.selected].item)
end

---Set the item that's been selected from the list
---@param item selectedItemType
function StoreScrollingListBox:setSelectedItem(item)
    debugPrint(item)
    self.selectedItem = item
end

---comment
---@return selectedItemType
function StoreScrollingListBox:getSelectedItem()
    return self.selectedItem
end

function StoreScrollingListBox:close()
    ISPanelJoypad.close(self)
end

return StoreScrollingListBox
