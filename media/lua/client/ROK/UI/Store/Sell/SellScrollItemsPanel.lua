local ShopItemsManager = require("ROK/ShopItemsManager")
local StoreScrollItemsPanel = require("ROK/UI/Store/Components/StoreScrollItemsPanel")
-----------

---@param pl IsoPlayer
---@param item InventoryItem
local function CheckPlayerContainersForItem(pl, item)
    local wornItems = pl:getWornItems()
    for i=0, wornItems:size() - 1 do
        local wornItem = wornItems:get(i)
        if wornItem then
            local cont = wornItem:getItem():getContainer()
            if cont and cont:getItemById(item:getID()) then
                return true
            end
        end
    end

    return false
end


---@param item InventoryItem
---@return boolean
local function CheckCanPutInSellTab(item)
    local pl = getPlayer()

    if pl:isEquipped(item) or pl:isEquippedClothing(item) then
        triggerEvent("PZEFT_OnFailedSellTransfer", "isEquipped")
        return false
    elseif item:isFavorite() then
        triggerEvent("PZEFT_OnFailedSellTransfer", "isFavorite")
        return false
    end


    local isValid = CheckPlayerContainersForItem(pl, item)
    if not isValid then
        debugPrint("Couldn't find item in players container, checking inventory")
        if luautils.haveToBeTransfered(pl, item) then
            triggerEvent("PZEFT_OnFailedSellTransfer", "haveToBeTransferred")
            return false
        end
    end

    return isValid
end




---@class SellScrollItemsPanel : StoreScrollItemsPanel
---@field removeBtnSize number
---@field hoveringRemoveBtn boolean
local SellScrollItemsPanel = StoreScrollItemsPanel:derive("SellScrollItemsPanel")

-- TODO Quality/status of the item should affect the price!

function SellScrollItemsPanel:new(x, y, width, height)
    local o = StoreScrollItemsPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    SellScrollItemsPanel.instance = o

    ---@type SellScrollItemsPanel
    return o
end

function SellScrollItemsPanel:initialise()
    StoreScrollItemsPanel.initialise(self)
end

---@param item InventoryItem
function SellScrollItemsPanel:addItem(item)
    -- Organize them here based on item:getName()
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
    local itemData = ShopItemsManager.GetItem(itemFullType)

    -- If an item doesn't exist in the DB, create a fake one here
    -- if itemData == nil then
    --     itemData = { basePrice = 100, sellMultiplier = 0.5 }
    -- end

    -- TODO Reimplement quality, we need to change the UI for this to work.
    --local sellData = self.sellItemsData[itemFullType]

    local sellPrice = itemData.basePrice * itemData.sellMultiplier
    local sellPriceStr = string.format("$%.2f x %d", tostring(sellPrice), tostring(amount))
    local sellPriceX = self:getWidth() - getTextManager():MeasureStringX(self.font, sellPriceStr) - 6

    self:drawText(sellPriceStr, sellPriceX - 5, y + 2, 1, 1, 1, a, self.font)


    return y + self.itemheight
end

-- TODO Document this
function StructureSellData(items)
    ---@alias sellItemsDataType table<string, table<integer, {id : number, fullType : string, quality : number}>>

    ---@type sellItemsDataType
    local sellItemsData = {}
    for i=1, #items do
        ---@type table<integer, InventoryItem>
        local it = items[i].item
        local fType = it[1]:getFullType()

        sellItemsData[fType] = {}
        for j=1, #it do
            ---@type InventoryItem
            local it2 = it[j]
            table.insert(sellItemsData[fType], {
                id = it2:getID(),
                fullType = fType,
                quality = 1})
        end
    end

    return sellItemsData
end

---Inside of scrollingListBox, this means we're overriding ScrollItemsPanel
---@param self BaseScrollItemsPanel
---@param x number
---@param y number
local function SellOnDragItem(self, x, y)
    if self.vscroll then
        self.vscroll.scrolling = false;
    end


    if ISMouseDrag.dragging then
        for i = 1, #ISMouseDrag.dragging do
            local itemTab = ISMouseDrag.dragging[i]
            for j = 1, #itemTab.items do
                ---@type InventoryItem
                local item = itemTab.items[j]
                if item and CheckCanPutInSellTab(item) then
                    self.parent:addItem(item)
                end
            end
        end
    end

    -- Cycle through the items and structure them in the correct way.
    self.sellItemsData = StructureSellData(self.items)
end

local function SellPrerender(self)
    if #self.items == 0 then
        local text = getText("IGUI_Shop_Sell_Tooltip")
        local textX = (self.width - getTextManager():MeasureStringX(UIFont.Medium, text)) / 4
        self:drawText(text, textX, 100, 1, 1, 1, 1, UIFont.Medium)
    end

    ISScrollingListBox.prerender(self)
end

function SellScrollItemsPanel:createChildren()
    StoreScrollItemsPanel.createChildren(self)

    self.scrollingListBox.doDrawItem = SellDoDrawItem
    self.scrollingListBox.onMouseUp = SellOnDragItem
    self.scrollingListBox.prerender = SellPrerender
    --self.scrollingListBox.onMouseMove = SellOnMouseMove

    self.scrollingListBox.itemheight = self.scrollingListBox.fontHgt + self.scrollingListBox.itemPadY * 2
    self.scrollingListBox.sellItemsData = {}
end

--- Check player inv and compare it to the alreadyDragged items. If an item is not in their inventory/backpacks anymore, delete it from the list
function SellScrollItemsPanel:update()
    StoreScrollItemsPanel.update(self)

    -- Check if added items are still in players'inv
    local pl = getPlayer()
    local plInv = pl:getInventory()

    for i=1, #self.scrollingListBox.items do
        local itemTab = self.scrollingListBox.items[i]
        for j=1, #itemTab.item do
            ---@type InventoryItem
            local item = itemTab.item[j]

            -- Check main inv 
            if plInv:getItemById(item:getID()) == nil then
                debugPrint("Item not in main inv => " .. item:getFullType())
                if CheckPlayerContainersForItem(pl, item) == false then
                    debugPrint("Removing item from sell list => " .. item:getFullType())
                    table.remove(self.scrollingListBox.items[i].item, j)

                    if #self.scrollingListBox.items[i].item == 0 then
                        table.remove(self.scrollingListBox.items, i)
                    end
                end

            end
        end
    end
end

return SellScrollItemsPanel
