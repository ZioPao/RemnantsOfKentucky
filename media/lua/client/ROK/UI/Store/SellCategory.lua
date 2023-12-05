local StoreScrollingListBox = require("ROK/UI/Store/Components/StoreScrollingListBox")
local SellSidePanel = require("ROK/UI/Store/SellSidePanel")
-----------------------

---@class SellCategory : StoreScrollingListBox
---@field shopPanel MainShopPanel
---@field sellSidePanel SellSidePanel
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

local function PrerenderItems(element)

    if #element.items == 0 then
        element:drawText(getText("IGUI_Shop_Sell_Tooltip"), 10, 100, 1, 1, 1, 1, UIFont.Medium)
    end

    ISScrollingListBox.prerender(element)
end

function SellCategory:createChildren()
    StoreScrollingListBox.createChildren(self)

    self.items.doDrawItem = self.onDrawItem
    self.items.onMouseUp = self.onDragItem
    self.items.prerender = PrerenderItems
    self.selected = 0

    local sellPanelWidth = self.width / 2 - 20
    local sellPanelX = self.width - sellPanelWidth - 10

    self.sellSidePanel = SellSidePanel:new(sellPanelX, self.panelYPadding, sellPanelWidth, self.panelHeight, self)
    self.sellSidePanel:initialise()
    self:addChild(self.sellSidePanel)
end

---@param id number
function SellCategory:addToDraggedItems(id)
    if self.draggedItems == nil then
        self.draggedItems = {}
    end

    self.draggedItems[id] = id
end

function SellCategory:checkDraggedItemsList(id)
    if self.draggedItems == nil then return false end

    if self.draggedItems[id] == id then return true else return false end
end

---Override onDragItem of sellList. This means that self is sellList
---@param x any
---@param y any
function SellCategory:onDragItem(x, y)
    -- TODO Should remove item from player!
    --debugPrint("on drag item")

    if self.vscroll then
        self.vscroll.scrolling = false
    end

    local count = 1
    if ISMouseDrag.dragging then
        local test = ISMouseDrag.dragging
        for i = 1, #ISMouseDrag.dragging do
            count = 1
            if instanceof(ISMouseDrag.dragging[i], "InventoryItem") then
                local item = ISMouseDrag.dragging[i]
                local itemID = item:getID()
                if not self.parent:checkDraggedItemsList(itemID) then
                    self.parent:addToDraggedItems(itemID)

                    -- TODO addItem with FullType, not count
                    self:addItem(count, ISMouseDrag.dragging[i])
                end
            else
                if ISMouseDrag.dragging[i].invPanel.collapsed[ISMouseDrag.dragging[i].name] then
                    count = 1
                    for j = 1, #ISMouseDrag.dragging[i].items do
                        if count > 1 then
                            ---@type InventoryItem
                            local item = ISMouseDrag.dragging[i].items[j]
                            local itemID = item:getID()
                            if not self.parent:checkDraggedItemsList(itemID) then
                                self.parent:addToDraggedItems(itemID)
                                self:addItem(count, item)
                            end
                        end
                        count = count + 1
                    end
                end
            end
        end
    end

    self.parent.sellSidePanel:updateInfoPanel()
end

---Override for sellList
---@param y number
---@param item {item : InventoryItem}
---@return number
function SellCategory:onDrawItem(y, item)
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, 0.9, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)
    if self.selected == item.index then         -- TODO Is this right? Check this again
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
    end

    local itemName = item.item:getName()
    self:drawText(itemName, 30, y + 2, 1, 1, 1, 0.9, self.font)

    self:drawTextureScaledAspect(item.item:getTex(), 5, y - 10, 18, 18, 1, item.item:getR(), item.item:getG(),
        item.item:getB())

    -- Add price
    local itemFullType = item.item:getFullType()
    local itemData = PZ_EFT_ShopItems_Config.data[itemFullType]

    if itemData == nil then
        itemData = {basePrice = 100, sellMultiplier = 0.5}
    end

    local sellPrice = itemData.basePrice * itemData.sellMultiplier
    local sellpriceStr = tostring(sellPrice) .. " $"
    local sellPriceX = self:getWidth() - getTextManager():MeasureStringX(self.font, sellpriceStr)

    self:drawText(sellpriceStr, sellPriceX - 5, y + 2, 1, 1, 1, 0.9, self.font)


    return y + self.itemheight
end


----------------------------------

function SellCategory:close()
    StoreScrollingListBox.close(self)
end

return SellCategory
