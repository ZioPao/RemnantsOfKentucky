local BaseScrollItemsPanel = require("ROK/UI/Store/Components/BaseScrollItemsPanel")
-----------

---@class SellScrollItemsPanel : BaseScrollItemsPanel
---@field removeBtnSize number
---@field hoveringRemoveBtn boolean
local SellScrollItemsPanel = BaseScrollItemsPanel:derive("SellScrollItemsPanel")

-- TODO Quality/status of the item should affect the price!

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
end

---@param item InventoryItem
function SellScrollItemsPanel:addItem(item)
    local pl = getPlayer()

    if luautils.haveToBeTransfered(pl, item) then
        triggerEvent("PZEFT_OnFailedSellTransfer", "haveToBeTransferred")
        return
    elseif pl:isEquipped(item) or pl:isEquippedClothing(item) then
        triggerEvent("PZEFT_OnFailedSellTransfer", "isEquipped")
        return
    elseif item:isFavorite() then
        triggerEvent("PZEFT_OnFailedSellTransfer", "isFavorite")
        return
    end


    -- TODO Organize them here based on item:getName()
    local itemName = item:getName()
    self.scrollingListBox:insertIntoItemTab(itemName, item)
end

---@param self ISScrollingListBox
---@param y number
---@param item {text : string, index : number, height : number, item : table<integer, InventoryItem>}
---@param alt boolean
---@return number
local function SellDoDrawItem(self, y, item, alt)
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, 0.9, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    local a = 0.9

    --* Item name
    local itemName = item.text
    self:drawText(itemName, 50, y + 2, 1, 1, 1, a, self.font)


    --* Amount of same items
    local amount = #item.item
    self:drawText(tostring(amount), 6, y + 2, 1, 1, 1, a, self.font)

    --* Price
    local itemFullType = item.item[1]:getFullType()
    local itemData = PZ_EFT_ShopItems_Config.data[itemFullType]

    if itemData == nil then
        itemData = { basePrice = 100, sellMultiplier = 0.5 }
    end

    local sellPrice = itemData.basePrice * itemData.sellMultiplier
    local sellpriceStr = "$" .. tostring(sellPrice) .. " x " .. tostring(amount)
    local sellPriceX = self:getWidth() - getTextManager():MeasureStringX(self.font, sellpriceStr) - 6

    self:drawText(sellpriceStr, sellPriceX - 5, y + 2, 1, 1, 1, a, self.font)


    return y + self.itemheight
end

---Inside of scrollingListBox, this means we're overriding ScrollItemsPanel
---@param self BaseScrollItemsPanel
---@param x number
---@param y number
local function SellOnDragItem(self, x, y)
    if self.vscroll then
        self.vscroll.scrolling = false;
    end
    local count = 1
    if ISMouseDrag.dragging then
        for i = 1, #ISMouseDrag.dragging do
            count = 1
            if instanceof(ISMouseDrag.dragging[i], "InventoryItem") then
                self.parent:addItem(ISMouseDrag.dragging[i])
            else
                if ISMouseDrag.dragging[i].invPanel.collapsed[ISMouseDrag.dragging[i].name] then
                    count = 1
                    for j = 1, #ISMouseDrag.dragging[i].items do
                        if count > 1 then
                            self.parent:addItem(ISMouseDrag.dragging[i].items[j])
                        end
                        count = count + 1
                    end
                end
            end
        end
    end
end

local function SellPrender(self)
    if #self.items == 0 then
        local text = getText("IGUI_Shop_Sell_Tooltip")
        local textX = (self.width - getTextManager():MeasureStringX(UIFont.Medium, text)) / 4
        self:drawText(text, textX, 100, 1, 1, 1, 1, UIFont.Medium)
    end

    ISScrollingListBox.prerender(self)
end

function SellScrollItemsPanel:createChildren()
    BaseScrollItemsPanel.createChildren(self)

    self.scrollingListBox.doDrawItem = SellDoDrawItem
    self.scrollingListBox.onMouseUp = SellOnDragItem
    self.scrollingListBox.prerender = SellPrender
    --self.scrollingListBox.onMouseMove = SellOnMouseMove

    self.scrollingListBox.itemheight = self.scrollingListBox.fontHgt + self.scrollingListBox.itemPadY * 2
end

--- Check player inv and compare it to the alreadyDragged items. If an item is not in their inventory anymore, delete it from the list
function SellScrollItemsPanel:update()
    BaseScrollItemsPanel.update(self)

    -- Check if added items are still in players'inv
    local pl = getPlayer()
    local plInv = pl:getInventory()
    for i = 1, #self.scrollingListBox.items do
        ---@type table
        local item = self.scrollingListBox.items[i].item
        for j=1, #item do
            ---@type InventoryItem
            local invItem = item[j]
            if plInv:getItemById(invItem:getID()) == nil or luautils.haveToBeTransfered(pl, invItem) or pl:isEquipped(invItem) or pl:isEquippedClothing(invItem) or invItem:isFavorite() then
                table.remove(self.scrollingListBox.items.item, j)
            end
        end

    end
end

return SellScrollItemsPanel
