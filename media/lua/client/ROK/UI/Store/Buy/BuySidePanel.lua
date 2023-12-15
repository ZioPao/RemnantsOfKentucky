local RightSidePanel = require("ROK/UI/Store/Components/RightSidePanel")
local ClientShopManager = require("ROK/Economy/ClientShopManager")
local ClientBankManager = require("ROK/Economy/ClientBankManager")
local CommonStore = require("ROK/UI/Store/Components/CommonStore")
local ShopItemsManager = require("ROK/ShopItemsManager")
------------------------

---@class BuySidePanel : RightSidePanel
---@field parent BuyMainPanel
---@field selectedAmount number
---@field currentCost number?
---@field shopCat string
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
    o.selectedAmount = 1
    o.timeShowBuyConfirmation = 0

    ---@cast o BuySidePanel
    return o
end

function BuySidePanel:createChildren()
    RightSidePanel.createChildren(self)

    local yMargin = CommonStore.MARGIN_Y

    self.bottomBtn:setTitle(getText("IGUI_Shop_Buy_Btn"))
    self.bottomBtn.internal = "BUY"
    self.bottomBtn:initialise()
    self.bottomBtn:setEnable(false)


    --* Amount
    local amountPanelWidth = self.width/2
    local elementAmountHeight = 50
    local amountPanelX = (self.width - amountPanelWidth)/2
    local elementAmountY = self.bottomBtn:getY() - yMargin

    self.amountPanel = ISRichTextPanel:new(amountPanelX, elementAmountY, amountPanelWidth, elementAmountHeight)
    self.amountPanel:initialise()
    self:addChild(self.amountPanel)
    self.amountPanel.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.amountPanel.borderColor = { r = 1, g = 1, b = 1, a = 1 }
    self.amountPanel.anchorTop = false
    self.amountPanel.anchorLeft = false
    self.amountPanel.anchorBottom = false
    self.amountPanel.anchorRight = false
    self.amountPanel.autosetheight = false
    self.amountPanel.marginLeft = 0
    self.amountPanel.marginTop = (self.amountPanel.height - getTextManager():MeasureStringY(self.amountPanel.font, "1"))/4
    self.amountPanel.marginRight = 0
    self.amountPanel.marginBottom = 0
    self.amountPanel:setText(" <CENTRE> 1")
    self.amountPanel:paginate()

    local btnWidth = self.width - self.amountPanel:getRight() - CommonStore.MARGIN_X

    self.amountMinusBtn = ISButton:new(CommonStore.MARGIN_X, elementAmountY, btnWidth, elementAmountHeight, "<", self, self.onClick)
    self.amountMinusBtn.internal = 'MINUS'
    self.amountMinusBtn:initialise()
    self.amountMinusBtn:instantiate()
    self:addChild(self.amountMinusBtn)

    self.amountPlusBtn = ISButton:new(self.amountPanel:getRight() + CommonStore.MARGIN_X, elementAmountY, btnWidth, elementAmountHeight, ">", self, self.onClick)
    self.amountPlusBtn.internal = 'PLUS'
    self.amountPlusBtn:initialise()
    self.amountPlusBtn:instantiate()
    self:addChild(self.amountPlusBtn)
end

function BuySidePanel:update()
    --debugPrint("BuySidePanel update")
    RightSidePanel.update(self)

    -- Calculate cost here
    local selectedItem = self.parent.scrollPanel:getSelectedItem()
    if selectedItem then

        self.amountMinusBtn:setEnable(self.selectedAmount > 1)
        self.amountPlusBtn:setEnable(self.selectedAmount < 99)

        local itemCost = selectedItem.basePrice
        self.currentCost = tonumber(self.selectedAmount) * itemCost

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
        self.amountPlusBtn:setEnable(false)
        self.amountMinusBtn:setEnable(false)
    end
end

---Reset the Selected Amount when we change selectedItem
function BuySidePanel:resetSelectedAmount()
    debugPrint("Running ResetSelectedAmount")
    self.selectedAmount = 1
end
Events.PZEFT_OnChangeSelectedItem.Add(BuySidePanel.resetSelectedAmount)

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
        local itemFinalCostStr = " <CENTRE> $" .. self.currentCost .. " x " .. tostring(self.selectedAmount) .. " = $" .. tostring(self.currentCost)
        finalStr = itemNameStr .. " <LINE> " .. itemFinalCostStr
    end

    if self.showBuyConfirmation then
        finalStr = finalStr .. " <LINE> " .. getText("IGUI_Shop_Buy_Confirmation_Success")

        local showTime = os.time()
        if showTime > self.timeShowBuyConfirmation then
            self.showBuyConfirmation = false
        end
    end


    if self.selectedAmount then
        local amountStr = tostring(self.selectedAmount)
        self.amountPanel:setText(" <CENTRE> " ..  amountStr)
        self.amountPanel.marginTop = (self.amountPanel.height - getTextManager():MeasureStringY(self.amountPanel.font, amountStr))/4
        self.amountPanel.textDirty = true
    end


    -- Updates the text in the panel
    self.textPanel:setText(finalStr)
    self.textPanel:paginate()
end

function BuySidePanel:onClick(btn)
    if btn.internal == 'BUY' then
        self:onStartBuy()
    elseif btn.internal == 'PLUS' then
        --debugPrint(">")
        self.selectedAmount = self.selectedAmount + 1
    elseif btn.internal == 'MINUS' then
        --debugPrint("<")
        self.selectedAmount = self.selectedAmount - 1
    end
end

function BuySidePanel:onStartBuy()
    debugPrint("Buy")
    local selectedItem = self.parent.scrollPanel:getSelectedItem()

    -- Starts separate confirmation panel
    local text = getText("IGUI_Shop_Buy_Confirmation", self.selectedAmount, selectedItem["actualItem"]:getDisplayName(), tostring(self.currentCost))
    self.parent:openConfirmationPanel(text, self.OnConfirmBuy)

end

---This runs from the parent panel!
---@param parent BuyMainPanel
function BuySidePanel.OnConfirmBuy(parent)
    debugPrint("Confirm buy")
    local selectedItem = parent.scrollPanel:getSelectedItem()
    local quantity = tonumber(parent.sidePanel.selectedAmount)
    if quantity == nil then return end
    local itemData = ShopItemsManager.GetItem(selectedItem.fullType)
    ClientShopManager.TryBuy(itemData, quantity, parent.shopCat)
end


return BuySidePanel