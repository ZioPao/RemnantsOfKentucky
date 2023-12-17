local BaseScrollItemsPanel = require("ROK/UI/BaseComponents/BaseScrollItemsPanel")
-----------

---@class StoreScrollItemsPanel : BaseScrollItemsPanel
local StoreScrollItemsPanel = BaseScrollItemsPanel:derive("BuyScrollItemsPanel")

---@param x any
---@param y any
---@param width any
---@param height any
---@param shopPanel any
---@return StoreScrollItemsPanel
function StoreScrollItemsPanel:new(x, y, width, height, shopPanel)
    local o = BaseScrollItemsPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    ---@cast o StoreScrollItemsPanel
    o.shopPanel = shopPanel
    StoreScrollItemsPanel.instance = o
    return o
end

---@param itemsTable table<string, {actualItem : Item, fullType : string}>
function StoreScrollItemsPanel:initialiseList(itemsTable)
    BaseScrollItemsPanel.initialiseList(self, itemsTable)

    -- Select first item in the list automatically
    if #itemsTable > 1 and self.buyPanel then
        self.scrollingListBox.selected = 1
        local selectedItem = self.scrollingListBox.items[self.scrollingListBox.selected].item
        self.buyPanel:setSelectedItem(selectedItem)
    end
end

---Set the item that's been selected from the list
---@param item selectedItemType
function StoreScrollItemsPanel:setSelectedItem(item)
    --debugPrint(item)
    if self.selectedItem ~= item then
        self.selectedItem = item
        -- Notify change
        debugPrint("Triggering PZEFT_OnChangeSelectedItem")
        triggerEvent("PZEFT_OnChangeSelectedItem", self.parent.sidePanel)
    end
end

return StoreScrollItemsPanel