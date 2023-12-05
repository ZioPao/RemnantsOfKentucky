-- Users should be able to drag n drop items in this panel to sell them.
-- Opens confirmation panel when you select "Sell". Compatible with Tarkov UI
local ConfirmationPanel = require("ROK/UI/ConfirmationPanel")
local ClientShopManager = require("ROK/Economy/ClientShopManager")
local RightSidePanel = require("ROK/UI/Store/Components/RightSidePanel")
------------------------

-- TODO ADD remove Item from list

---@class SellSidePanel : RightSidePanel
---@field infoPanel ISPanel
---@field mainPanel SellCategory
local SellSidePanel = RightSidePanel:derive("SellSidePanel")

---@param x number
---@param y number
---@param width number
---@param height number
---@param mainPanel SellCategory
---@return SellSidePanel
function SellSidePanel:new(x, y, width, height, mainPanel)
    local o = RightSidePanel:new(x, y, width, height, mainPanel)
    setmetatable(o, self)
    self.__index = self

    ---@cast o SellSidePanel
    return o
end

function SellSidePanel:createChildren()
    RightSidePanel.createChildren(self)

    self.bottomBtn:setTitle("Sell")      -- TODO GetText
    self.bottomBtn.internal = "SELL"
    self.bottomBtn:initialise()
    self.bottomBtn:setEnable(false)
end

----------------------------------

---Runs after clicking the SELL button
---@param btn ISButton
function SellSidePanel:onClick(btn)
    debugPrint("Sell function")

    local text = "Are you sure you want to sell these items?"
    local x = self.parent.parent:getX()
    local y = self.parent.parent:getY() + self.parent.parent:getHeight() + 20

    self.confirmationPanel = ConfirmationPanel.Open(text, x, y, self, self.onConfirmSell)
end

---Runs after you confirm that you want to sell
function SellSidePanel:onConfirmSell()
    -- TODO Rewrite this
    debugPrint("OnConfirmSell")

    local itemsTosell = {}

    for i=1, #self.mainPanel.items.items do
        ---@type InventoryItem
        local item = self.mainPanel.items.items[i].item
        local fullType = item:getFullType()

        ---@type shopItemElement
        local itemData = PZ_EFT_ShopItems_Config.data[fullType]
        if itemData == nil then
            itemData = {basePrice = 100, sellMultiplier = 0.5}
        end

        local itemTable = {
            item = {
                fullType = fullType,
                basePrice = itemData.basePrice,
                multiplier = 1,
                sellMultiplier = itemData.sellMultiplier,
            },
            quantity = 1,
        }

        table.insert(itemsTosell, itemTable)
    end

    -- Try to sell it and removes item on the client
    if ClientShopManager.TrySell(itemsTosell) then
        local plInv = getPlayer():getInventory()
        for i=1, #self.mainPanel.items.items do
            ---@type InventoryItem
            local item = self.mainPanel.items.items[i].item
            ISRemoveItemTool.removeItem(item, getPlayer())
        end
    end
    -- This is from the Btn context, so we need to go one parent out
    -- These names suck ass

    self.textPanel:setText("")
    self.textPanel.textDirty = true
    self.parent.draggedItems = {}
    self.parent.items.items = {}        -- Clean it
end

function SellSidePanel:calculateSellPrice()
    --debugPrint(#self.sellList.items)
    local price = 0

    for i=1, #self.mainPanel.items.items do
        ---@type InventoryItem
        local item = self.mainPanel.items.items[i].item
        local fullType = item:getFullType()

        ---@type shopItemElement
        local itemData = PZ_EFT_ShopItems_Config.data[fullType]

        if itemData == nil then
            itemData = {basePrice = 100, sellMultiplier = 0.5}
        end

        local itemPrice = itemData.basePrice * itemData.sellMultiplier
        price = price + itemPrice

    end

    return price
end

---Triggered when the user drags a item into the scrollingList
function SellSidePanel:updateInfoPanel()

    -- TODO URGENT! This is a placeholder for now!

    local price = self:calculateSellPrice()
    self.textPanel:setText("<CENTRE> You will receive: " .. tostring(price) .. "$")
    self.textPanel.textDirty = true


    -- Count amount of items
    local itemsAmount = #self.mainPanel.items.items
    self.bottomBtn:setEnable(itemsAmount > 0)
end

function SellSidePanel:render()
    RightSidePanel.render(self)
    --self:drawText("SELL_CATEGORYSELL_CATEGORYSELL_CATEGORYSELL_CATEGORYSELL_CATEGORYSELL_CATEGORYSELL_CATEGORYSELL_CATEGORY", -200, self.height /2, 1, 1, 1, 1, UIFont.Medium)

end


return SellSidePanel
