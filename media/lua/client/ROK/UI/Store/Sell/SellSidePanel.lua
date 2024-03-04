
local ClientShopManager = require("ROK/Economy/ClientShopManager")
local ShopItemsManager = require("ROK/ShopItemsManager")
local RightSidePanel = require("ROK/UI/Store/Components/RightSidePanel")
------------------------

local notificationsTable = {
    haveToBeTransfered = getText("IGUI_Shop_Sell_HaveToBeTransferred"),
    isEquipped = getText("IGUI_Shop_Sell_IsEquipped"),
    isFavorite =  getText("IGUI_Shop_Sell_IsFavorite"),
    successful = getText("IGUI_Shop_Sell_Confirmation_Success")
}

---@class SellSidePanel : RightSidePanel
---@field showNotification boolean
---@field notificationType string
---@field timeShowNotification number
local SellSidePanel = RightSidePanel:derive("SellSidePanel")

function SellSidePanel:new(x, y, width, height)
    local o = RightSidePanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o:initialise()
    o.showNotification = false
    o.notificationType = ""
    o.timeShowNotification = 0

    SellSidePanel.instance = o

    ---@cast o BuySidePanel
    return o
end

function SellSidePanel:createChildren()
    RightSidePanel.createChildren(self)

    self.bottomBtn:setTitle(getText("IGUI_Shop_Sell_Btn"))
    self.bottomBtn.internal = "SELL"
    self.bottomBtn:initialise()
    self.bottomBtn:setEnable(false)
end

function SellSidePanel:render()
    RightSidePanel.render(self)

    ---@type sellItemsDataType
    local sellItemsData = self.parent.scrollPanel.scrollingListBox.sellItemsData
    local text = ""
    local price = self:getTotalSellPrice(sellItemsData)


    if price > 0 then
        text = string.format("<CENTRE> You will receive: $%.2f", tostring(price))
    end

    if self.showNotification then

        if self.notificationType ~= 'successful' then
            text = text .. " <LINE> <CENTRE> <RED> Can't add item, "
        end
        text = text .. notificationsTable[self.notificationType]

        local showTime = os.time()
        if showTime > self.timeShowNotification then
            self.showNotification = false
        end
    end

    self.textPanel:setText(text)
    self.textPanel.textDirty = true
end

function SellSidePanel:update()
    RightSidePanel.update(self)
    -- Count amount of items
    local itemsAmount = #self.parent.scrollPanel.scrollingListBox.items
    local enableSell = self.confirmationPanelRef == nil or not self.confirmationPanelRef:isVisible()

    self.bottomBtn:setEnable(itemsAmount > 0 and enableSell)
end

function SellSidePanel:onClick(btn)
    if btn.internal ~= "SELL" then return end

    self:onStartSell()
end

function SellSidePanel:onStartSell()
    local text = getText("IGUI_Shop_Sell_Confirmation")
    self.confirmationPanelRef = self.parent:openConfirmationPanel(text, function()
        self:onConfirmSell()
    end)
end

function SellSidePanel:onConfirmSell()
    debugPrint("OnConfirmSell")

    ---@type SellMainPanel
    local parent = self.parent

    -- Try to sell it and removes item on the client
    ClientShopManager.TrySell(parent:getSellItemsData())

    -- Clean stuff
    self.textPanel:setText("")
    self.textPanel.textDirty = true
    self.parent.scrollPanel.draggedItems = {}
    self.parent.scrollPanel.scrollingListBox.items = {}
    self.parent.scrollPanel.scrollingListBox.sellItemsData = {}
    
end

---@param val boolean
---@param cat string
function SellSidePanel:updateNotification(val, cat)
    self.showNotification = val
    self.notificationType = cat
    self.timeShowNotification = os.time() + 3
end

---@param sellItemsData sellItemsDataType
---@return number
function SellSidePanel:getTotalSellPrice(sellItemsData)
    local price = 0
    for fullType, dataTable in pairs(sellItemsData) do
        local itemData = ShopItemsManager.GetItem(fullType)
        local bPrice = itemData.basePrice
        local sellMult = itemData.sellMultiplier
        local quantity = #dataTable
        -- TODO Reimplement quality
        price = price + (bPrice * sellMult * quantity)
    end


    return price
end


return SellSidePanel