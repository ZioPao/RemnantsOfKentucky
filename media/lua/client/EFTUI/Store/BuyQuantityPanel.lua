-- TODO A basic confirmation panel when you're buying stuff. Asks how how much stuff you want of that specific object and then exec the transaction

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

    -- TODO Add entry for amount
    self.entryAmount = ISTextEntryBox:new("", 10, self.height / 2, self.width / 2 - 10, 25)
    self.entryAmount:initialise()
    self.entryAmount:instantiate()
    self.entryAmount:setText("")
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

--***** Setters ******--

---Set the item that's been selected from the list
---@param item Item
function BuyQuantityPanel:setSelectedItem(item)
    self.selectedItem = item
end

function BuyQuantityPanel:onConfirmBuy()
    print("Confirm buy")
end

function BuyQuantityPanel:onStartBuy()
    print("Buy")

    -- Starts separate confirmation panel
    local text = " <CENTRE> Are you sure you wanna buy X amount of this item?"
    self.confirmationPanel = ConfirmationPanel.Open(text, self.mainPanel:getX(),
        self.mainPanel:getY() + self.mainPanel:getHeight() + 20, self.onConfirmBuy, self)
end

function BuyQuantityPanel:onClick(btn)
    if btn.internal == 'BUY' then
        self:onStartBuy()
    end
end

function BuyQuantityPanel:update()
    ISPanel.update(self)

    if self.mainPanel:getJavaObject() == nil then self:close() end

    if self.selectedItem == nil then return end


    self.textPanel:setText(" <CENTRE> " .. self.selectedItem:getName())
    self.textPanel:paginate()


    -- TODO Update icon here

    -- FIXME this doesn't stop!!!
    local icon = self.selectedItem:getIcon()
    --print(icon)
    local iconSize = 50

    if self.selectedItem:getIconsForTexture() and not self.selectedItem:getIconsForTexture():isEmpty() then
        icon = self.selectedItem:getIconsForTexture():get(0)
    end
    if icon then
        local texture = getTexture("Item_" .. icon)
        if texture then
            self:drawTextureScaledAspect2(texture, 0, 0, iconSize, iconSize, 1, 1, 1, 1)
        end
    end
end

function BuyQuantityPanel:close()
    print("Closing BuyQuantityPanel")
    ISPanel.close(self)
end

return BuyQuantityPanel