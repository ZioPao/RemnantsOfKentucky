
local ClientShopManager = require("ROK/Economy/ClientShopManager")
local RightSidePanel = require("ROK/UI/Store/Components/RightSidePanel")
local ShopItemsManager = require("ROK/ShopItemsManager")
------------------------

-- TODO ADD remove Item from list

-- TODO Use getText
local notificationsTable = {}
notificationsTable["haveToBeTransferred"] = "it needs to be transferred"
notificationsTable["isEquipped"] = "it's equipped"
notificationsTable["isFavorite"] = "it's a favorite"
notificationsTable["successful"] = getText("IGUI_Shop_Sell_Confirmation_Success")

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

    ---@type sellData
    local sellItemsData = self.parent.scrollPanel.scrollingListBox.sellItemsData
    local itemsAmount = #sellItemsData
    local text

    if itemsAmount > 0 then
        local price = self:getTotalSellPrice(sellItemsData)
        text = string.format("<CENTRE> You will receive: $%.2f", tostring(price))
    else
        text = ""
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
    self.bottomBtn:setEnable(itemsAmount > 0)
end

function SellSidePanel:onClick(btn)
    if btn.internal ~= "SELL" then return end

    self:onStartSell()
end

function SellSidePanel:onStartSell()
    local text = getText("IGUI_Shop_Sell_Confirmation")
    self.parent:openConfirmationPanel(text, function()
        self:onConfirmSell()
    end)
end

function SellSidePanel:onConfirmSell()
    debugPrint("OnConfirmSell")

    ---@type SellMainPanel
    local parent = self.parent
    local itemsToSell = parent:getSellItemsData()

    -- Try to sell it and removes item on the client
    ClientShopManager.TrySell(itemsToSell)

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

---@param sellItemsData sellData
---@return number
function SellSidePanel:getTotalSellPrice(sellItemsData)
    local price = 0
    for i=1, #sellItemsData do
        local data = sellItemsData[i]
        local bPrice = data.itemData.basePrice
        local sellMult = data.itemData.sellMultiplier
        local quantity = data.quantity
        local quality = data.quality
        price = price + (bPrice * sellMult * quantity * quality)
    end

    return price
end


return SellSidePanel