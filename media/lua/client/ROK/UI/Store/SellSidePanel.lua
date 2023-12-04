-- Users should be able to drag n drop items in this panel to sell them.
-- Opens confirmation panel when you select "Sell". Compatible with Tarkov UI
local ConfirmationPanel = require("ROK/UI/ConfirmationPanel")
local RightSidePanel = require("ROK/UI/Store/Components/RightSidePanel")
------------------------

-- TODO ADD remove Item from list
-- TODO This is broken now for some reason



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

    -- TODO Doesn't work with Mainpanel
    local text = "Are you sure you want to sell these items?"
    local x = self.parent.parent:getX()
    local y = self.parent.parent:getY() + self.parent.parent:getHeight() + 20

    self.confirmationPanel = ConfirmationPanel.Open(text, x, y, self, self.onConfirmSell)
end

---Runs after you confirm that you want to sell
function SellSidePanel:onConfirmSell()
    -- TODO Finish this
    debugPrint("OnConfirmSell")

    -- This is from the Btn context, so we need to go one parent out
    -- These names suck ass
    self.parent.items.items = {}        -- Clean it
end

function SellSidePanel:calculateSellPrice()
    --debugPrint(#self.sellList.items)
    local price = 0

    for i=1, #self.mainPanel.items.items do
        price = price + i + ZombRand(0, 10)
        local fullType = "test" --self.mainPanel.items.items
        -- TODO Use FullType

        ---@type shopItemElement
        local itemData = PZ_EFT_ShopItems_Config.data[fullType]

        if itemData == nil then
            itemData = {basePrice = 1000}
        end

        local itemPrice = itemData.basePrice * 0.5
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
    --self.infoPanel:setText("Money that you will receive: 10000$")
    --self.infoPanel.textDirty = true

    -- Count amount of items
    local itemsAmount = #self.mainPanel.items.items
    self.bottomBtn:setEnable(itemsAmount > 0)
end

function SellSidePanel:render()
    RightSidePanel.render(self)

end


return SellSidePanel
