--[[
    A panel that will appear on the right of the scrolling list.
    Asks how how much stuff you want of that specific object, show the total cost, and has a button to exec the transaction
]]
local BuyQuantityPanel = ISPanel:derive("BuyQuantityPanel")

---Starts a new quantity panel
---@param x number
---@param y number
---@param width number
---@param height number
---@param mainPanel ISCollapsableWindow
---@return ISPanel
function BuyQuantityPanel:new(x, y, width, height, mainPanel)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o:initialise()
    o.mainPanel = mainPanel
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.7 }
    o.fullItemsList = getAllItems()

    BuyQuantityPanel.instance = o
    return o
end

function BuyQuantityPanel:createChildren()
    ISPanel.createChildren(self)

    self.textPanel = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.textPanel:initialise()
    self:addChild(self.textPanel)
    self.textPanel.defaultFont = UIFont.Medium
    self.textPanel.anchorTop = true
    self.textPanel.anchorLeft = false
    self.textPanel.anchorBottom = true
    self.textPanel.anchorRight = false
    self.textPanel.marginLeft = 0
    self.textPanel.marginTop = 10
    self.textPanel.marginRight = 0
    self.textPanel.marginBottom = 0
    self.textPanel.autosetheight = false
    self.textPanel.background = false
    self.textPanel:setText("")
    self.textPanel:paginate()

    local xMargin = 10
    local yMargin = 20
    local elementHeight = 50

    self.entryAmount = ISTextEntryBox:new("1", xMargin, elementHeight + (self.height / 2), self.width - xMargin * 2,
        elementHeight)
    self.entryAmount:initialise()
    self.entryAmount:instantiate()
    self.entryAmount:setClearButton(true)
    self.entryAmount:setOnlyNumbers(true)
    self.entryAmount:setMaxTextLength(2)
    self:addChild(self.entryAmount)


    self.btnBuy = ISButton:new(xMargin, self.entryAmount:getBottom() + yMargin, self.width - xMargin * 2, elementHeight *
        2, "Buy", self,
        self.onClick)
    self.btnBuy.internal = "BUY"
    self.btnBuy:initialise()
    self.btnBuy:setEnable(true)
    self:addChild(self.btnBuy)
end

---Set the item that's been selected from the list
---@param item Item
function BuyQuantityPanel:setSelectedItem(item)
    self.selectedItem = item
end

function BuyQuantityPanel:getCostForSelectedItem()
    local itemCost = self.selectedItem["cost"]
    local finalCost = tonumber(self.entryAmount:getInternalText()) * itemCost
    return finalCost
end

function BuyQuantityPanel:onConfirmBuy()
    -- TODO Add Transaction function here
    print("Confirm buy")
end

function BuyQuantityPanel:onStartBuy()
    print("Buy")


    -- TODO Disable text entry for the amount of items from here

    -- Starts separate confirmation panel

    local text = " <CENTRE> Are you sure you want to buy " ..
        tostring(self.entryAmount:getInternalText()) ..
        " of " .. self.selectedItem["item"]:getName() .. " for " .. tostring(self:getCostForSelectedItem()) .. "$ ?"

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
        local actualItem = getScriptManager():getItem(self.selectedItem["fullType"])
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
