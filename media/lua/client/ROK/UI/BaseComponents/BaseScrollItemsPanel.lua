local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
local TilesScrollingListBox = require("ROK/UI/BaseComponents/TilesScrollingListBox")
-----------------------


---@class BaseScrollItemsPanel : ISPanelJoypad
---@field parent StoreContainerPanel
local BaseScrollItemsPanel = ISPanelJoypad:derive("BaseScrollItemsPanel")

---@param x number
---@param y number
---@param width number
---@param height number
---@return BaseScrollItemsPanel
function BaseScrollItemsPanel:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    ---@cast o BaseScrollItemsPanel
    BaseScrollItemsPanel.instance = o
    return o
end

function BaseScrollItemsPanel:initalise()
    ISPanelJoypad.initialise(self)
end

---@param itemsTable table<string, {actualItem : Item, fullType : string}>
function BaseScrollItemsPanel:initialiseList(itemsTable)
    if itemsTable == nil then return end
    local sortedItems = {}

    for k,v in pairs(itemsTable) do
        v.actualItem = getScriptManager():getItem(v.fullType)
        if v.actualItem ~= nil then
            table.insert(sortedItems, v)        -- FIXME Workaround, it could prevent from reaching the desired amount of daily items
        end
    end

    ---@param a {actualItem : Item}
    ---@param b {actualItem : Item}
    ---@return boolean
    local function SortByName(a,b)
        return a.actualItem:getDisplayName() < b.actualItem:getDisplayName()
    end

    table.sort(sortedItems, SortByName)

    -- Sorting

    for i=1, #sortedItems do
        local data = sortedItems[i]
        data.actualItem = getScriptManager():getItem(data.fullType)
        self.scrollingListBox:addItem(data.fullType, data)

    end

    -- Select first item in the list automatically
    if #itemsTable > 1 then
        self.scrollingListBox.selected = 1
    end
end


---This is run on the the ScrollingBoxList!
---@param x number
---@param y number
local function ScrollingListBoxOnMouseDown(self, x, y)
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

    self.parent:setSelectedItem(self.items[self.selected].item)
end

function BaseScrollItemsPanel:createChildren()
    self.panelYPadding = GenericUI.SMALL_FONT_HGT + 2 * 2
    self.panelHeight = self.height - self.panelYPadding - 10

    self.scrollingListBox = TilesScrollingListBox:new(0, 0, self.width, self.height, 3)
    self.scrollingListBox:initialise()
    self.scrollingListBox:instantiate()
    self.scrollingListBox:setAnchorRight(false) -- resize in update()
    self.scrollingListBox:setAnchorBottom(true)
    self.scrollingListBox.itemHeight = 2 + GenericUI.MEDIUM_FONT_HGT + 32 + 4
    self.scrollingListBox.selected = 0
    self.scrollingListBox.onMouseDown = ScrollingListBoxOnMouseDown
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

---@return selectedItemType
function BaseScrollItemsPanel:getSelectedItem()
    return self.selectedItem
end

function BaseScrollItemsPanel:close()
    ISPanelJoypad.close(self)
end

return BaseScrollItemsPanel
