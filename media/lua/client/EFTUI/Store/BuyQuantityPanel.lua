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
---@return ISPanel
function BuyQuantityPanel:new(x, y, width, height, mainPanel)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o:initialise()
    o.mainPanel = mainPanel
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.7 }

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

    self.entryAmount = ISTextEntryBox:new("1", 10, self.height / 2, self.width / 2 - 10, 25)
    self.entryAmount:initialise()
    self.entryAmount:instantiate()
    self.entryAmount:setClearButton(true)
    self.entryAmount:setOnlyNumbers(true)
    self:addChild(self.entryAmount)


    self.btnBuy = ISButton:new(self.entryAmount:getRight() + 10, self.height / 2, self.width / 2 - 20, 25, "Buy", self,
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
        -- TODO Add print of total cost based on amount

        local actualItem = self.selectedItem["item"]
        local itemCost = self.selectedItem["cost"]

        local finalCost = tonumber(self.entryAmount:getInternalText()) * itemCost

        local itemNameStr = " <CENTRE> " .. actualItem:getName()
        local itemFinalCostStr = " <CENTRE> " ..
        itemCost .. "$ x " .. tostring(self.entryAmount:getInternalText()) .. "$ = " .. tostring(finalCost) .. "$"

        local finalStr = itemNameStr .. " <LINE> " .. itemFinalCostStr


        -- Text
        self.textPanel:setText(finalStr)
        self.textPanel:paginate()

        local icon = actualItem:getIcon()
        if actualItem:getIconsForTexture() and not actualItem:getIconsForTexture():isEmpty() then
            icon = actualItem:getIconsForTexture():get(0)
        end
        if icon then
            --print(icon)
            local texture = getTexture("Item_" .. icon)
            if texture then
                --print("Found texture, rendering")
                self:drawTextureScaledAspect2(texture, self.textPanel.x + 20, self.textPanel.y + 20, 50, 50, 1, 1, 1, 1)
            end
        end
    end
end

function BuyQuantityPanel:close()
    --print("Closing BuyQuantityPanel")

    if self.confirmationPanel then
        self.confirmationPanel:close()
    end

    ISPanel.close(self)
end

return BuyQuantityPanel
