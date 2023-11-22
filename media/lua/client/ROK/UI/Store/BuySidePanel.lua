-- A panel that will appear on the right of the scrolling list.
-- Asks how how much stuff you want of that specific object, show the total cost, and has a button to exec the transaction

-------------------------
local ConfirmationPanel = require("ROK/UI/ConfirmationPanel")
local ClientShopManager = require("ROK/Economy/ClientShopManager")
local RightSidePanel = require("ROK/UI/Store/Components/RightSidePanel")
local CommonStore = require("ROK/UI/Store/Components/CommonStore")
------------------------

---@alias selectedItemType {actualItem : string, basePrice : number}

---@class BuySidePanel : RightSidePanel
---@field mainPanel ISPanel
local BuySidePanel = RightSidePanel:derive("BuyQuantityPanel")

---Starts a new quantity panel
---@param x number
---@param y number
---@param width number
---@param height number
---@param mainPanel ISCollapsableWindow
---@return BuySidePanel
function BuySidePanel:new(x, y, width, height, mainPanel)
    local o = RightSidePanel:new(x, y, width, height, mainPanel)
    setmetatable(o, self)
    self.__index = self

    o:initialise()
    BuySidePanel.instance = o

    ---@cast o BuySidePanel
    return o
end

function BuySidePanel:createChildren()
    RightSidePanel.createChildren(self)

    local xMargin = CommonStore.MARGIN_X
    local yMargin = CommonStore.MARGIN_Y
    local elementX = xMargin
    local elementY = self:getBottom() - CommonStore.BIG_BTN_HEIGHT -  CommonStore.MARGIN_Y
    local elementWidth = self.width - xMargin * 2
    local elementHeight = CommonStore.BIG_BTN_HEIGHT

    self.bottomBtn:setTitle("Buy")      -- TODO GetText
    self.bottomBtn.internal = "BUY"
    self.bottomBtn:initialise()
    self.bottomBtn:setEnable(false)

    elementY = self.bottomBtn:getY() - elementHeight - yMargin

    self.entryAmount = ISTextEntryBox:new("1", elementX, elementY, elementWidth, elementHeight)
    self.entryAmount:initialise()
    self.entryAmount:instantiate()
    self.entryAmount:setClearButton(true)
    self.entryAmount:setOnlyNumbers(true)
    self.entryAmount:setMaxTextLength(2)
    self:addChild(self.entryAmount)
end

function BuySidePanel:update()
    RightSidePanel.update(self)
    self.bottomBtn:setEnable(self.selectedItem ~= nil)
end

function BuySidePanel:getCostForSelectedItem()
    local itemCost = self.selectedItem["basePrice"]
    local finalCost = tonumber(self.entryAmount:getInternalText()) * itemCost
    return finalCost
end

function BuySidePanel:onConfirmBuy()
    debugPrint("Confirm buy")
    local itemTable = {
        fullType = self.selectedItem["fullType"],
        basePrice = self.selectedItem["basePrice"],
        multiplier = 1 -- FIXME This should be with the selectedItem, but it's not there for some reason
    }

    local quantity = tonumber(self.entryAmount:getInternalText())
    ClientShopManager.TryBuy(itemTable, quantity)
end

function BuySidePanel:onStartBuy()
    debugPrint("Buy")

    -- TODO Disable text entry for the amount of items from here

    -- Starts separate confirmation panel

    local text = " <CENTRE> Are you sure you want to buy " ..
        tostring(self.entryAmount:getInternalText()) ..
        " of " ..
        self.selectedItem["actualItem"]:getName() .. " for " .. tostring(self:getCostForSelectedItem()) .. "$ ?"

    self.confirmationPanel = ConfirmationPanel.Open(text, self.mainPanel:getX(),
        self.mainPanel:getY() + self.mainPanel:getHeight() + 20, self, self.onConfirmBuy)
end

function BuySidePanel:onClick(btn)
    if btn.internal == 'BUY' then
        self:onStartBuy()
    end
end

function BuySidePanel:render()
    RightSidePanel.render(self)

    if self.selectedItem == nil then return end

    -- Handle icons
    local actualItem = self.selectedItem.actualItem
    local icon = actualItem:getIcon()
    if actualItem:getIconsForTexture() and not actualItem:getIconsForTexture():isEmpty() then
        icon = actualItem:getIconsForTexture():get(0)
    end
    if icon then
        local texture = getTexture("Item_" .. icon)
        if texture then
            self:drawTextureScaledAspect2(texture, self.textPanel.x + 20, self.textPanel.y + 20, 50, 50, 1, 1, 1, 1)
        end
    end

    -- Handle Text
    local itemCost = self.selectedItem.basePrice
    local entryAmountText = self.entryAmount:getInternalText()
    if entryAmountText == nil or entryAmountText == "" or entryAmountText == "0" then
        self.entryAmount:setText("1")
    end

    local finalCost = tonumber(self.entryAmount:getInternalText()) * itemCost

    local itemNameStr = " <CENTRE> " .. actualItem:getDisplayName()
    local itemFinalCostStr = " <CENTRE> " ..
        itemCost .. "$ x " .. tostring(self.entryAmount:getInternalText()) .. "$ = " .. tostring(finalCost) .. "$"

    local finalStr = itemNameStr .. " <LINE> " .. itemFinalCostStr

    -- Updates the text in the panel
    self.textPanel:setText(finalStr)
    self.textPanel:paginate()
end

function BuySidePanel:close()
    if self.confirmationPanel then
        self.confirmationPanel:close()
    end

    RightSidePanel.close(self)
end

return BuySidePanel
