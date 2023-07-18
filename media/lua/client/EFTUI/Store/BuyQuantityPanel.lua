-- TODO A basic confirmation panel when you're buying stuff. Asks how how much stuff you want of that specific object and then exec the transaction

BuyQuantityPanel = ConfirmationPanel:derive("BuyQuantityPanel")

---Starts a new quantity panel
---@param x number
---@param y number
---@param width number
---@param height number
---@param item? InventoryItem
---@return ISPanel
function BuyQuantityPanel:new(x, y, width, height, item)
    local confirmationText

    if item then
        confirmationText = "Are you sure you wanna buy " .. item:getName() .. "?"
    else
        confirmationText = "Select an item"
    end

    local o = ConfirmationPanel:new(x, y, width, height, confirmationText, self.onConfirmBuy, self)
    setmetatable(o, self)
    self.__index = self

    o:initialise()
    BuyQuantityPanel.instance = o
    return o
end

function BuyQuantityPanel:onConfirmBuy()
    -- TODO Execute transaction for the amount selected
end

function BuyQuantityPanel:createChildren()
    ConfirmationPanel.createChildren(self)

    self.btnYes:setTitle("Buy")
    self.btnNo:setTitle("Cancel")

    -- TODO Add entry for amount
    self.entryAmount = ISTextEntryBox:new("", 10, self.height/2, self.width - 20, 25)
    self.entryAmount:initialise()
    self.entryAmount:instantiate()
    self.entryAmount:setText("")
    self.entryAmount:setClearButton(true)
    self.entryAmount:setOnlyNumbers(true)
    self:addChild(self.entryAmount)

end

function BuyQuantityPanel:update()
    ISPanel.update(self)

    
end


-------------------------
-- Mostly debug stuff

function BuyQuantityPanel.Open(alertText, x, y, onConfirmFunc)
    local width = 500
    local height = 120

    local panel = BuyQuantityPanel:new(x, y, width, height, alertText, onConfirmFunc)
    panel:initialise()
    panel:addToUIManager()
    panel:bringToTop()
    return panel
end

function BuyQuantityPanel.Close()
    BuyQuantityPanel.instance:close()
end
