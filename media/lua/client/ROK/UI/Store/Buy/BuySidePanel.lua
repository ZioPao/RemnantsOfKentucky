local RightSidePanel = require("ROK/UI/Store/Components/RightSidePanel")
local ClientShopManager = require("ROK/Economy/ClientShopManager")
local ClientBankManager = require("ROK/Economy/ClientBankManager")
local CommonStore = require("ROK/UI/Store/Components/CommonStore")
------------------------


-- TODO Use functions in CLientShopManager, not here

---@class BuySidePanel : RightSidePanel
---@field parent BuyMainPanel
---@field currentCost number?
---@field showBuyConfirmation boolean
---@field timeShowBuyConfirmation number
local BuySidePanel = RightSidePanel:derive("BuySidePanel")

---Starts a new quantity panel
---@param x number
---@param y number
---@param width number
---@param height number
---@return BuySidePanel
function BuySidePanel:new(x, y, width, height)
    local o = RightSidePanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o:initialise()
    o.showBuyConfirmation = false
    o.timeShowBuyConfirmation = 0

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

    self.bottomBtn:setTitle(getText("IGUI_Shop_Buy_Btn"))
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

function BuySidePanel:setSuccessfulBuyConfirmation(val)
    self.showBuyConfirmation = val
    self.timeShowBuyConfirmation = os.time() + 3
end

function BuySidePanel:update()
    --debugPrint("BuySidePanel update")
    RightSidePanel.update(self)

    -- Calculate cost here
    local selectedItem = self.parent.scrollPanel:getSelectedItem()
    if selectedItem then
        local itemCost = selectedItem.basePrice
        local entryAmountText = self.entryAmount:getInternalText()
        if entryAmountText == nil or entryAmountText == "" or entryAmountText == "0" then
            self.entryAmount:setText("1")
        end
        self.currentCost = tonumber(self.entryAmount:getInternalText()) * itemCost

        -- We've already requested the bank account from the Main Shop panel
        local balance = ClientBankManager.GetPlayerBankAccountBalance()
        if balance < self.currentCost then
            self.bottomBtn:setEnable(false)
            self.bottomBtn:setTooltip(getText("IGUI_Shop_Buy_Btn_NoCash_Tooltip"))
        else
            self.bottomBtn:setEnable(true)
            self.bottomBtn:setTooltip(nil)
        end
    else
        self.bottomBtn:setEnable(false)
    end
end

function BuySidePanel:render()
    RightSidePanel.render(self)
    local selectedItem = self.parent.scrollPanel:getSelectedItem()

    if selectedItem == nil then return end

    -- Handle icons
    local actualItem = selectedItem.actualItem
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
    local finalStr
    if self.currentCost == nil then
        finalStr = " <CENTRE> Loading..."
    else
        local itemNameStr = " <CENTRE> " .. actualItem:getDisplayName()
        local itemFinalCostStr = " <CENTRE> $" .. self.currentCost .. " x " .. tostring(self.entryAmount:getInternalText()) .. " = $" .. tostring(self.currentCost)
        finalStr = itemNameStr .. " <LINE> " .. itemFinalCostStr
    end

    if self.showBuyConfirmation then
        finalStr = finalStr .. " <LINE> " .. getText("IGUI_Shop_Buy_Confirmation_Success")

        local showTime = os.time()
        if showTime > self.timeShowBuyConfirmation then
            self.showBuyConfirmation = false
        end
    end


    -- Updates the text in the panel
    self.textPanel:setText(finalStr)
    self.textPanel:paginate()
end

function BuySidePanel:onClick(btn)
    if btn.internal == 'BUY' then
        self:onStartBuy()
    end
end

function BuySidePanel:onStartBuy()
    debugPrint("Buy")
    local selectedItem = self.parent.scrollPanel:getSelectedItem()
    local cost = self:getCostForSelectedItem()      -- TODO We're getting selectedItem again here, optimize it

    -- TODO Disable text entry for the amount of items from here

    -- Starts separate confirmation panel
    local text = getText("IGUI_Shop_Buy_Confirmation", self.entryAmount:getInternalText(), selectedItem["actualItem"]:getName(), tostring(cost))
    self.parent:openConfirmationPanel(text, self.OnConfirmBuy)

end

---This runs from the parent panel!
---@param parent BuyMainPanel
function BuySidePanel.OnConfirmBuy(parent)
    debugPrint("Confirm buy")
    local selectedItem = parent.scrollPanel:getSelectedItem()
    local itemTable = {
        fullType = selectedItem["fullType"],
        basePrice = selectedItem["basePrice"],
        multiplier = 1 -- FIXME This should be with the selectedItem, but it's not there for some reason
    }

    local quantity = tonumber(parent.sidePanel.entryAmount:getInternalText())
    local isSuccessful = ClientShopManager.TryBuy(itemTable, quantity)
    parent.sidePanel:setSuccessfulBuyConfirmation(isSuccessful)

end


return BuySidePanel