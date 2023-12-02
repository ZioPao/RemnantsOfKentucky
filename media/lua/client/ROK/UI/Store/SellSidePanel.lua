-- Users should be able to drag n drop items in this panel to sell them.
-- Opens confirmation panel when you select "Sell". Compatible with Tarkov UI
local ConfirmationPanel = require("ROK/UI/ConfirmationPanel")
local RightSidePanel = require("ROK/UI/Store/Components/RightSidePanel")
------------------------

-- TODO ADD remove Item from list
-- TODO This is broken now for some reason



---@class SellSidePanel : RightSidePanel
---@field infoPanel ISPanel
local SellSidePanel = RightSidePanel:derive("SellSidePanel")

---@param x number
---@param y number
---@param width number
---@param height number
---@param mainPanel any
---@return SellSidePanel
function SellSidePanel:new(x, y, width, height, mainPanel)
    local o = RightSidePanel:new(x, y, width, height, mainPanel)
    setmetatable(o, self)
    self.__index = self

    o.draggedItems = {}

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
function SellSidePanel:onClickSell(btn)
    debugPrint("Sell function")
    self.confirmationPanel = ConfirmationPanel.Open("Are you sure you want to sell these items?", self.mainPanel:getX(),
    self.mainPanel:getY() + self.mainPanel:getHeight() + 20, self, self.onConfirmSell)
end

---Runs after you confirm that you want to sell
function SellSidePanel:onConfirmSell()
    debugPrint("OnConfirmSell")

    self.sellList.items = {}        -- Clean it
end

function SellSidePanel:calculateSellPrice()
    --debugPrint(#self.sellList.items)
    local price = 0

    for i=1, #self.sellList.items do
        price = price + i + ZombRand(0, 10)
    end

    return price
end

---Triggered when the user drags a item into the scrollingList
function SellSidePanel:updateInfoPanel()
    -- TODO Update text with info about the transaction

    local price = self:calculateSellPrice()
    --debugPrint(price)
    self.textPanel:setText("test sell side panel")

    --self.infoPanel:setText("Money that you will receive: 10000$")
    --self.infoPanel.textDirty = true

    -- Count amount of items
    self.bottomBtn:setEnable(#self.sellList.items > 0)
end

function SellSidePanel:render()
    RightSidePanel.render(self)

end
----------------------------------

function SellSidePanel:addToDraggedItems(id)
    if self.draggedItems == nil then
        self.draggedItems = {}
    end

    self.draggedItems[id] = id
end



return SellSidePanel
