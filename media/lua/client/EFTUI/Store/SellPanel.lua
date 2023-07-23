--[[
    Users should be able to drag n drop items in this panel to sell them.
    Opens confirmation panel when you select "Sell". Compatible with Tarkov UI
]]
    local SellPanel = ISPanel:derive("SellPanel")


function SellPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    return o
end

function SellPanel:createChildren()

    local padding = 10

	self.sellList = ISScrollingListBox:new(padding, padding, (self.width - padding*2)/2, self.height - padding*4)
    self.sellList:initialise()
    self.sellList:instantiate()
    self.sellList.itemheight = 22
    self.sellList.selected = 0
    self.sellList.joypadParent = self
    self.sellList.font = UIFont.NewSmall
    self.sellList.doDrawItem = self.onDrawItem
    self.sellList.onMouseUp = self.onDragItem
    self.sellList.drawBorder = true
    self:addChild(self.sellList)

    --* Info panels and buttons, on the right
    local infoX = self.sellList:getRight() + padding
    local infoY = padding

    self.infoPanel = ISRichTextPanel:new(infoX, infoY, (self.width - padding*2)/2, (self.height - padding*4)/2)
    self.infoPanel:initialise()
    self:addChild(self.infoPanel)
    self.infoPanel.defaultFont = UIFont.Medium
    self.infoPanel.anchorTop = true
    self.infoPanel.anchorLeft = false
    self.infoPanel.anchorBottom = true
    self.infoPanel.anchorRight = false
    self.infoPanel.marginLeft = 0
    self.infoPanel.marginTop = padding
    self.infoPanel.marginRight = 0
    self.infoPanel.marginBottom = 0
    self.infoPanel.autosetheight = false
    self.infoPanel.background = false
    self.infoPanel:setText("")
    self.infoPanel:paginate()

    infoY = infoY*2 + self.infoPanel:getBottom()

    self.btnSell = ISButton:new(infoX, infoY, self.infoPanel:getWidth() - padding, 50, "Sell", self, self.onClick)
    self.btnSell.internal = "SELL"
    self.btnSell:initialise()
    self.btnSell:setEnable(false)
    self:addChild(self.btnSell)
end


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
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, 0.9, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if self.selected == item.index then
		self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
    end

    local itemName = item.item:getName()
	self:drawText(itemName, 25, y + 2, 1, 1, 1, 0.9, self.font)

    self:drawTextureScaledAspect(item.item:getTex(), 5, y + 2, 18, 18, 1, item.item:getR(), item.item:getG(), item.item:getB())

    return y + self.itemheight

end

return SellPanel