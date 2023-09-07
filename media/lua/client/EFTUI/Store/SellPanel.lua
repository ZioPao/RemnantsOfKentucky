--[[
    Users should be able to drag n drop items in this panel to sell them.
    Opens confirmation panel when you select "Sell". Compatible with Tarkov UI
]]
local SellPanel = ISPanelJoypad:derive("SellPanel")


function SellPanel:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    return o
end

function SellPanel:createChildren()
    local fontHgtSmall = EFTGenericUI.SMALL_FONT_HGT
    local entryHgt = fontHgtSmall + 2 * 2

    local xMargin = 10


    self.sellList = ISScrollingListBox:new(xMargin, entryHgt, self.width / 2, self.height - (entryHgt))
    self.sellList:initialise()
    self.sellList:instantiate()
    self.sellList:setAnchorRight(false) -- resize in update()
    self.sellList:setAnchorBottom(true)
    self.sellList.itemHeight = 2 + EFTGenericUI.MEDIUM_FONT_HGT + 32 + 4
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
    self:addChild(self.infoPanel)

    self.btnSell = ISButton:new(xMargin, self.infoPanel:getHeight()/2, self.infoPanel:getWidth() - xMargin*2, 50, "Sell", self, self.onClick)
    self.btnSell.internal = "SELL"
    self.btnSell:initialise()
    self.btnSell:setEnable(false)
    self.infoPanel:addChild(self.btnSell)
end


----------------------------------


---Triggered when the user drags a item into the scrollingList
function SellPanel:updateInfoPanel()
    -- TODO Update text with info about the transaction
    self.infoPanel:setText("Money that you will receive: 10000$")
    self.infoPanel.textDirty = true
end

function SellPanel:onDragItem(x, y)
    if self.vscroll then
        self.vscroll.scrolling = false
    end
    local count = 1
    if ISMouseDrag.dragging then
        for i = 1, #ISMouseDrag.dragging do
            count = 1
            if instanceof(ISMouseDrag.dragging[i], "InventoryItem") then
                self:addItem(count, ISMouseDrag.dragging[i])
            else
                if ISMouseDrag.dragging[i].invPanel.collapsed[ISMouseDrag.dragging[i].name] then
                    count = 1
                    for j = 1, #ISMouseDrag.dragging[i].items do
                        if count > 1 then
                            self:addItem(count, ISMouseDrag.dragging[i].items[j])
                        end
                        count = count + 1
                    end
                end
            end
        end
    end

    self.parent:updateInfoPanel()
end

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
