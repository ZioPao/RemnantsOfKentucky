local BaseScrollItemsPanel = require("ROK/UI/Store/Components/BaseScrollItemsPanel")
-----------

---@class SellScrollItemsPanel : BaseScrollItemsPanel
---@field draggeditems {}
local SellScrollItemsPanel = BaseScrollItemsPanel:derive("SellScrollItemsPanel")

function SellScrollItemsPanel:new(x, y, width, height)
    local o = BaseScrollItemsPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    SellScrollItemsPanel.instance = o

    ---@type SellScrollItemsPanel
    return o
end

function SellScrollItemsPanel:initialise()
    BaseScrollItemsPanel.initialise(self)

    self.draggedItems = {}
end

local function SellDoDrawItem(self, y, item, alt)
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, 0.9, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    local a = 0.9
    --* Item name
    local itemName = item.item:getName()
    self:drawText(itemName, 6, y + 2, 1, 1, 1, a, UIFont.Medium)

    --* Price
    local itemFullType = item.item:getFullType()
    local itemData = PZ_EFT_ShopItems_Config.data[itemFullType]

    if itemData == nil then
        itemData = {basePrice = 100, sellMultiplier = 0.5}
    end

    local sellPrice = itemData.basePrice * itemData.sellMultiplier
    local sellpriceStr = "$" .. tostring(sellPrice)
    local sellPriceX = self:getWidth() - getTextManager():MeasureStringX(UIFont.Medium, sellpriceStr)

    self:drawText(sellpriceStr, sellPriceX - 5, y + 2, 1, 1, 1, a, UIFont.Medium)


    return y + self.itemheight
end

---Inside of scrollingListBox, this means we're overriding ScrollItemsPanel
---@param self BaseScrollItemsPanel
---@param x number
---@param y number
local function SellOnDragItem(self, x, y)
    -- This is ok, this happens because we're overriding OnMouseUp
    ---@type SellScrollItemsPanel
    local parent = self.parent

    ---@cast parent SellScrollItemsPanel

    if self.vscroll then
        self.vscroll.scrolling = false
    end

    local count = 1
    if ISMouseDrag.dragging then
        for i = 1, #ISMouseDrag.dragging do
            count = 1
            if instanceof(ISMouseDrag.dragging[i], "InventoryItem") then
                local item = ISMouseDrag.dragging[i]
                local itemID = item:getID()
                if not parent:isItemAlreadyDraggedIn(itemID) then
                    parent:addToDraggedItems(itemID)

                    -- TODO addItem with FullType, not count
                    self:addItem(itemID, ISMouseDrag.dragging[i])
                end
            else
                if ISMouseDrag.dragging[i].invPanel.collapsed[ISMouseDrag.dragging[i].name] then
                    count = 1
                    for j = 1, #ISMouseDrag.dragging[i].items do
                        if count > 1 then
                            ---@type InventoryItem
                            local item = ISMouseDrag.dragging[i].items[j]
                            local itemID = item:getID()
                            if not parent:isItemAlreadyDraggedIn(itemID) then
                                parent:addToDraggedItems(itemID)
                                self:addItem(itemID, item)
                            end
                        end
                        count = count + 1
                    end
                end
            end
        end
    end


    --self.parent.sidePanel:updateInfoPanel()
end

local function SellPrender(self)
    if #self.items == 0 then
        self:drawText(getText("IGUI_Shop_Sell_Tooltip"), 10, 100, 1, 1, 1, 1, UIFont.Medium)
    end

    ISScrollingListBox.prerender(self)
end

function SellScrollItemsPanel:createChildren()
    BaseScrollItemsPanel.createChildren(self)

    self.scrollingListBox.doDrawItem = SellDoDrawItem
    self.scrollingListBox.onMouseUp = SellOnDragItem
    self.scrollingListBox.prerender = SellPrender
end

--- Check player inv and compare it to the alreadyDragged items. If an item is not in their inventory anymore, delete it from the list
function SellScrollItemsPanel:update()
    BaseScrollItemsPanel.update(self)

    local plInv = getPlayer():getInventory()
    for _, v in pairs(self.draggedItems) do
        if v ~= nil and plInv:getItemById(v) == nil then
            self:removeDraggedItem(v)
            self.scrollingListBox:removeItem(v)
        end
    end
end

---@param id number
function SellScrollItemsPanel:addToDraggedItems(id)
    self.draggedItems[id] = id
end

---@param id number
function SellScrollItemsPanel:removeDraggedItem(id)
    self.draggedItems[id] = nil
end

---@param id number
function SellScrollItemsPanel:isItemAlreadyDraggedIn(id)
    if self.draggedItems == nil then return false end
    if self.draggedItems[id] == id then return true else return false end
end

return SellScrollItemsPanel