-- TODO Users should be able to drag n drop items in this panel to sell them. Opens confirmation panel. Compatible with Tarkov UI

local SellPanel = ISPanel:derive("SellPanel")


function SellPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    return o
end

function SellPanel:createChildren()
	self.sellList = ISScrollingListBox:new(10, 10, self.width - 20, self.height - 20)
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
