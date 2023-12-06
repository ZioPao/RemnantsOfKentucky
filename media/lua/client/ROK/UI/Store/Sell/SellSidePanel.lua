
local ClientShopManager = require("ROK/Economy/ClientShopManager")
local RightSidePanel = require("ROK/UI/Store/Components/RightSidePanel")
------------------------

-- TODO ADD remove Item from list

---@class SellSidePanel : RightSidePanel
local SellSidePanel = RightSidePanel:derive("SellSidePanel")

function SellSidePanel:new(x, y, width, height)
    local o = RightSidePanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o:initialise()
    SellSidePanel.instance = o

    ---@cast o BuySidePanel
    return o
end

function SellSidePanel:createChildren()
    RightSidePanel.createChildren(self)

    self.bottomBtn:setTitle("Sell")      -- TODO GetText
    self.bottomBtn.internal = "SELL"
    self.bottomBtn:initialise()
    self.bottomBtn:setEnable(false)
end

function SellSidePanel:render()
    RightSidePanel.render(self)

    -- TODO if nothing is in, set text to "" and stop
    local text = ""

    local price = self:calculateSellPrice()
    self.textPanel:setText("<CENTRE> You will receive: " .. tostring(price) .. "$")
    self.textPanel.textDirty = true
end

function SellSidePanel:update()
    RightSidePanel.update(self)
    -- Count amount of items
    local itemsAmount = #self.parent.scrollPanel.scrollingListBox.items
    self.bottomBtn:setEnable(itemsAmount > 0)
end
function SellSidePanel:onClick(btn)
    if btn.internal ~= "SELL" then return end

    self:onStartSell()
end

function SellSidePanel:onStartSell()
    local text = "Are you sure you want to sell these items?"
    self.parent:openConfirmationPanel(text, function()
        self:onConfirmSell()
    end)
end

function SellSidePanel:onConfirmSell()
    debugPrint("OnConfirmSell")
    local itemsTosell = {}

    local itemsList = self.parent.scrollPanel.scrollingListBox.items

    -- Cycle through the items and structure them in the correct way
    for i=1, #itemsList do
        ---@type InventoryItem
        local item = itemsList[i].item
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
        for i=1, #itemsList do
            ---@type InventoryItem
            local item = itemsList[i].item
            ISRemoveItemTool.removeItem(item, getPlayer())
        end
    end

    -- Clean stuff
    self.textPanel:setText("")
    self.textPanel.textDirty = true
    self.parent.scrollPanel.draggedItems = {}
    self.parent.scrollPanel.scrollingListBox.items = {}
end

function SellSidePanel:calculateSellPrice()
    local price = 0
    local itemsList = self.parent.scrollPanel.scrollingListBox.items

    for i=1, #itemsList do
        ---@type InventoryItem
        local item = itemsList[i].item
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


return SellSidePanel