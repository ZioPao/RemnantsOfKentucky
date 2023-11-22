-- Users should be able to drag n drop items in this panel to sell them.
-- Opens confirmation panel when you select "Sell". Compatible with Tarkov UI

local GenericUI = require("ROK/UI/GenericUI")
local ConfirmationPanel = require("ROK/UI/ConfirmationPanel")
local CommonStore = require("ROK/UI/Store/CommonStore")
------------------------

-- TODO ADD remove Item from list

---@class SellPanel : ISPanelJoypad
---@field infoPanel ISPanel
local SellPanel = ISPanelJoypad:derive("SellPanel")

---@param x number
---@param y number
---@param width number
---@param height number
---@return SellPanel
function SellPanel:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.draggedItems = {}

    ---@cast o SellPanel
    return o
end

function SellPanel:createChildren()
    local fontHgtSmall = GenericUI.SMALL_FONT_HGT
    local entryHgt = fontHgtSmall + 2 * 2
    local xMargin = 10

    self.sellList = ISScrollingListBox:new(xMargin, entryHgt, self.width / 2, self.height - (entryHgt))
    self.sellList:initialise()
    self.sellList:instantiate()
    self.sellList:setAnchorRight(false) -- resize in update()
    self.sellList:setAnchorBottom(true)
    self.sellList.itemHeight = 2 + GenericUI.MEDIUM_FONT_HGT + 32 + 4
    self.sellList.selected = 0
    self.sellList.doDrawItem = self.onDrawItem
    self.sellList.onMouseUp = self.onDragItem
    self.sellList.joypadParent = self
    self.sellList.drawBorder = true
    self:addChild(self.sellList)

    --* Info panels and buttons, on the right
    local infoPanelWidth = self.width / 2 - 20
    local infoPanelHeight = self.height - entryHgt
    local infoPanelX = self.width - infoPanelWidth - xMargin
    local infoPanelY = entryHgt

    self.infoPanel = ISPanel:new(infoPanelX, infoPanelY, infoPanelWidth, infoPanelHeight)
    self.infoPanel:initialise()
    self.infoPanel.backgroundColor = { r = 0, g = 0, b = 0, a = 0.7 }
    self:addChild(self.infoPanel)

    local yMargin = CommonStore.MARGIN_Y

    local elementWidth = infoPanelWidth - (xMargin * 2)
    local elementHeight = CommonStore.BIG_BTN_HEIGHT
    local elementX = CommonStore.MARGIN_X
    local elementY = self.infoPanel:getBottom() - elementHeight - yMargin

    self.btnSell = ISButton:new(elementX, elementY, elementWidth, elementHeight, "Sell", self, self.onClickSell)
    self.btnSell.internal = "SELL"
    self.btnSell:initialise()
    self.btnSell:setEnable(false)
    self.infoPanel:addChild(self.btnSell)
end

----------------------------------

---Runs after clicking the SELL button
---@param btn ISButton
function SellPanel:onClickSell(btn)
    debugPrint("Sell function")
    self.confirmationPanel = ConfirmationPanel.Open("Are you sure you want to sell these items?", self.mainPanel:getX(),
    self.mainPanel:getY() + self.mainPanel:getHeight() + 20, self, self.onConfirmSell)
end

---Runs after you confirm that you want to sell
function SellPanel:onConfirmSell()
    debugPrint("OnConfirmSell")

    self.sellList.items = {}        -- Clean it
end

function SellPanel:calculateSellPrice()
    --debugPrint(#self.sellList.items)
    local price = 0

    for i=1, #self.sellList.items do
        price = price + i + ZombRand(0, 10)
    end

    return price
end

---Triggered when the user drags a item into the scrollingList
function SellPanel:updateInfoPanel()
    -- TODO Update text with info about the transaction

    local price = self:calculateSellPrice()
    --debugPrint(price)

    --self.infoPanel:setText("Money that you will receive: 10000$")
    --self.infoPanel.textDirty = true

    -- Count amount of items
    self.btnSell:setEnable(#self.sellList.items > 0)
end


----------------------------------

function SellPanel:addToDraggedItems(id)
    if self.draggedItems == nil then
        self.draggedItems = {}
    end

    self.draggedItems[id] = id
end

---Override onDragItem of sellList. This means that self is sellList
---@param x any
---@param y any
function SellPanel:onDragItem(x, y)

    -- TODO Should remove item from player!

    if self.vscroll then
        self.vscroll.scrolling = false
    end
    local count = 1
    if ISMouseDrag.dragging then
        for i = 1, #ISMouseDrag.dragging do
            count = 1
            if instanceof(ISMouseDrag.dragging[i], "InventoryItem") then
                local id = ISMouseDrag.dragging[i]:getID()
                if self.parent.draggedItems[id] == nil then
                    self:addItem(count, ISMouseDrag.dragging[i])
                    self.parent:addToDraggedItems(ISMouseDrag.dragging[i]:getID())
                end

            else
                if ISMouseDrag.dragging[i].invPanel.collapsed[ISMouseDrag.dragging[i].name] then
                    count = 1
                    for j = 1, #ISMouseDrag.dragging[i].items do
                        if count > 1 then
                            local id = ISMouseDrag.dragging[i].items[j]:getID()
                            if self.parent.draggedItems[id] == nil then
                                self:addItem(count, ISMouseDrag.dragging[i].items[j])
                                self.parent:addToDraggedItems(id)
                            end
                        end
                        count = count + 1
                    end
                end
            end
        end
    end

    self.parent:updateInfoPanel()
end

---Override for sellList
---@param y any
---@param item any
---@param alt any
---@return unknown
function SellPanel:onDrawItem(y, item, alt)
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, 0.9, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)
    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
    end

    local itemName = item.item:getName()
    self:drawText(itemName, 25, y + 2, 1, 1, 1, 0.9, self.font)

    self:drawTextureScaledAspect(item.item:getTex(), 5, y + 2, 18, 18, 1, item.item:getR(), item.item:getG(),
        item.item:getB())

    return y + self.itemheight
end


return SellPanel
