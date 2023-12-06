local GenericUI = require("ROK/UI/GenericUI")
-----------------------

---@class BaseScrollItemsPanel : ISPanelJoypad
---@field parent StoreContainerPanel
local BaseScrollItemsPanel = ISPanelJoypad:derive("BaseScrollItemsPanel")

---comment
---@param x any
---@param y any
---@param width any
---@param height any
---@param shopPanel any
---@return BaseScrollItemsPanel
function BaseScrollItemsPanel:new(x, y, width, height, shopPanel)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    ---@cast o BaseScrollItemsPanel
    o.shopPanel = shopPanel
    BaseScrollItemsPanel.instance = o
    return o
end

function BaseScrollItemsPanel:initalise()
    ISPanelJoypad.initialise(self)
end

---@param itemsTable any
function BaseScrollItemsPanel:initialiseList(itemsTable)
    if itemsTable == nil then return end

    for tableName, data in pairs(itemsTable) do
        data.actualItem = getScriptManager():getItem(tableName)
        self.scrollingListBox:addItem(tableName, data)
    end

    -- Select first item in the list automatically
    if #itemsTable > 1 then
        self.scrollingListBox.selected = 1
        local selectedItem = self.scrollingListBox.items[self.scrollingListBox.selected].item
        self.buyPanel:setSelectedItem(selectedItem)
    end
end

function BaseScrollItemsPanel:createChildren()
    self.panelYPadding = GenericUI.SMALL_FONT_HGT + 2 * 2
    self.panelHeight = self.height - self.panelYPadding - 10

    self.scrollingListBox = ISScrollingListBox:new(10, self.panelYPadding, self.width / 2, self.panelHeight)
    self.scrollingListBox:initialise()
    self.scrollingListBox:instantiate()
    self.scrollingListBox:setAnchorRight(false) -- resize in update()
    self.scrollingListBox:setAnchorBottom(true)
    self.scrollingListBox.itemHeight = 2 + GenericUI.MEDIUM_FONT_HGT + 32 + 4
    self.scrollingListBox.selected = 0
    self.scrollingListBox.onMouseDown = BaseScrollItemsPanel.onMouseDownItems
    self.scrollingListBox.joypadParent = self
    self.scrollingListBox.drawBorder = true
    self:addChild(self.scrollingListBox)

    self.scrollingListBox.SMALL_FONT_HGT = GenericUI.SMALL_FONT_HGT
    self.scrollingListBox.MEDIUM_FONT_HGT = GenericUI.MEDIUM_FONT_HGT
end

----------------------------------
function BaseScrollItemsPanel:update()
    --debugPrint("BaseScrollItemsPanel update")
    if not self.parent:getIsVisible() then return end
end

function BaseScrollItemsPanel:prerender()
    ISPanelJoypad.prerender(self)

end

---This is run on the the ScrollingBoxList!
---@param x number
---@param y number
function BaseScrollItemsPanel:onMouseDownItems(x, y)
    if #self.scrollingListBox == 0 then return end
    local row = self:rowAt(x, y)

    if row > #self.scrollingListBox then
        row = #self.scrollingListBox
    end
    if row < 1 then
        row = 1
    end

    getSoundManager():playUISound("UISelectListItem")
    self.selected = row
    if self.onmousedown then
        self.onmousedown(self.target, self.scrollingListBox[self.selected].item)
    end

    -- TODO Send data to the BuyQuantityPanel

    self.parent:setSelectedItem(self.scrollingListBox[self.selected].item)
end

---Set the item that's been selected from the list
---@param item selectedItemType
function BaseScrollItemsPanel:setSelectedItem(item)
    debugPrint(item)
    self.selectedItem = item
end

---comment
---@return selectedItemType
function BaseScrollItemsPanel:getSelectedItem()
    return self.selectedItem
end

function BaseScrollItemsPanel:close()
    ISPanelJoypad.close(self)
end

return BaseScrollItemsPanel
