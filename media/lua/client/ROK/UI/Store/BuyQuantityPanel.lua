-- A panel that will appear on the right of the scrolling list.
-- Asks how how much stuff you want of that specific object, show the total cost, and has a button to exec the transaction

-------------------------
local ConfirmationPanel = require("ROK/UI/ConfirmationPanel")
local GenericUI = require("ROK/UI/GenericUI")
local CommonStore = require("ROK/UI/Store/CommonStore")

local ClientShopManager = require("ROK/Economy/ClientShopManager")
------------------------


---@class BuyQuantityPanel : ISPanel
---@field mainPanel ISPanel
local BuyQuantityPanel = ISPanel:derive("BuyQuantityPanel")

---Starts a new quantity panel
---@param x number
---@param y number
---@param width number
---@param height number
---@param mainPanel ISCollapsableWindow
---@return BuyQuantityPanel
function BuyQuantityPanel:new(x, y, width, height, mainPanel)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o:initialise()
    o.mainPanel = mainPanel
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.7 }

    BuyQuantityPanel.instance = o

    ---@cast o BuyQuantityPanel
    return o
end

function BuyQuantityPanel:createChildren()
    ISPanel.createChildren(self)

    GenericUI.CreateISRichTextPanel(self, "textPanel", 0, 0, self.width, self.height)

    local xMargin = CommonStore.MARGIN_X
    local yMargin = CommonStore.MARGIN_Y

    local elementX = xMargin
    local elementY = self:getBottom() - CommonStore.BIG_BTN_HEIGHT -  CommonStore.MARGIN_Y
    local elementWidth = self.width - xMargin * 2
    local elementHeight = CommonStore.BIG_BTN_HEIGHT

    self.btnBuy = ISButton:new(elementX, elementY, elementWidth, elementHeight, "Buy", self, self.onClick)
    self.btnBuy.internal = "BUY"
    self.btnBuy:initialise()
    self.btnBuy:setEnable(false)
    self:addChild(self.btnBuy)

    elementY = self.btnBuy:getY() - elementHeight - yMargin

    self.entryAmount = ISTextEntryBox:new("1", elementX, elementY, elementWidth, elementHeight)
    self.entryAmount:initialise()
    self.entryAmount:instantiate()
    self.entryAmount:setClearButton(true)
    self.entryAmount:setOnlyNumbers(true)
    self.entryAmount:setMaxTextLength(2)
    self:addChild(self.entryAmount)
end

function BuyQuantityPanel:update()
    ISPanel.update(self)
    self.btnBuy:setEnable(self.selectedItem ~= nil)
end

---Set the item that's been selected from the list
---@param item Item
function BuyQuantityPanel:setSelectedItem(item)
    self.selectedItem = item
end

function BuyQuantityPanel:getCostForSelectedItem()
    local itemCost = self.selectedItem["basePrice"]
    local finalCost = tonumber(self.entryAmount:getInternalText()) * itemCost
    return finalCost
end

function BuyQuantityPanel:onConfirmBuy()
    debugPrint("Confirm buy")
    local itemTable = {
        fullType = self.selectedItem["fullType"],
        basePrice = self.selectedItem["basePrice"],
        multiplier = 1 -- FIXME This should be with the selectedItem, but it's not there for some reason
    }

    local quantity = tonumber(self.entryAmount:getInternalText())
    ClientShopManager.TryBuy(itemTable, quantity)
end

function BuyQuantityPanel:onStartBuy()
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

function BuyQuantityPanel:onClick(btn)
    if btn.internal == 'BUY' then
        self:onStartBuy()
    end
end

function BuyQuantityPanel:render()
    ISPanel.render(self)

    if self.selectedItem ~= nil then
        -- Handle icons
        local actualItem = self.selectedItem["actualItem"]
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

        local itemCost = self.selectedItem["basePrice"]
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
end

function BuyQuantityPanel:close()
    if self.confirmationPanel then
        self.confirmationPanel:close()
    end

    ISPanel.close(self)
end

return BuyQuantityPanel
