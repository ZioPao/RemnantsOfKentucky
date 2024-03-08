-- Modified ISScrolligListBox, multiple in same line

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

---@class TilesScrollingListBox : ISScrollingListBox
---@field elementsPerRow number
---@field itemWidth number
local TilesScrollingListBox = ISScrollingListBox:derive("TilesScrollingListBox")

---@return TilesScrollingListBox
function TilesScrollingListBox:new(x, y, width, height, elementsPerRow)
    local o = ISScrollingListBox:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.itemheight = o.fontHgt + o.itemPadY * 6
    o.elementsPerRow = elementsPerRow

    o.itemWidth = o.width/o.elementsPerRow
    o.font = UIFont.Small


    return o
end

function TilesScrollingListBox:rowAt(x,y)
	local y0 = 0
    local x0 = 0
	for i,v in ipairs(self.items) do
		if not v.height then v.height = self.itemheight end -- compatibililty

        if (y>= y0 and y < y0 + v.height) and (x >= x0 and x < x0 + self.itemWidth)  then
            return i
        end

        x0 = x0 + self.itemWidth
        if i % self.elementsPerRow == 0 then
            y0 = y0 + v.height
            x0 = 0
        end
	end
	return -1
end

function TilesScrollingListBox:setElementsPerRow(elementsPerRow)
    self.elementsPerRow = elementsPerRow
    self.itemWidth = self.width/self.elementsPerRow
end

function TilesScrollingListBox:onMouseWheel(del)
    self:setYScroll(self:getYScroll() - (del*24))
    return true
end

function TilesScrollingListBox:prerender()
    if self.items == nil then
		return
	end
    -- debugPrint("Starting prerender")

	local stencilX = 0
	local stencilY = 0
	local stencilX2 = self.width
	local stencilY2 = self.height

    self:drawRect(0, -self:getYScroll(), self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
	if self.drawBorder then
		self:drawRectBorder(0, -self:getYScroll(), self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
		stencilX = 1
		stencilY = 1
		stencilX2 = self.width - 1
		stencilY2 = self.height - 1
	end

	if self:isVScrollBarVisible() then
		stencilX2 = self.vscroll.x + 3 -- +3 because the scrollbar texture is narrower than the scrollbar width
	end

	-- This is to handle this listbox being inside a scrolling parent.
	if self.parent and self.parent:getScrollChildren() then
		stencilX = self.javaObject:clampToParentX(self:getAbsoluteX() + stencilX) - self:getAbsoluteX()
		stencilX2 = self.javaObject:clampToParentX(self:getAbsoluteX() + stencilX2) - self:getAbsoluteX()
		stencilY = self.javaObject:clampToParentY(self:getAbsoluteY() + stencilY) - self:getAbsoluteY()
		stencilY2 = self.javaObject:clampToParentY(self:getAbsoluteY() + stencilY2) - self:getAbsoluteY()
	end
	self:setStencilRect(stencilX, stencilY, stencilX2 - stencilX, stencilY2 - stencilY)

	local y = 0
	local alt = false

	if self.selected ~= -1 and self.selected > #self.items then
		self.selected = #self.items
	end

	local altBg = self.altBgColor

	self.listHeight = 0

    local elementInRow = 0

    local i = 1
    for k, v in ipairs(self.items) do
    	if not v.height then v.height = self.itemheight end -- compatibililty

        if alt and altBg then
            self:drawRect(elementInRow * self.itemWidth, y, self.itemWidth, v.height-1, altBg.r, altBg.g, altBg.b, altBg.a)
        end
        v.index = i

        local y2 = self:doDrawItem(y, v, elementInRow)
        elementInRow = elementInRow + 1
        if elementInRow >= self.elementsPerRow then
            y = y2
            elementInRow = 0
            self.listHeight = y2
        end
        alt = not alt
        i = i + 1
    end

    self:setScrollHeight(y)
	self:clearStencilRect()
	if self.doRepaintStencil then
		self:repaintStencilRect(stencilX, stencilY, stencilX2 - stencilX, stencilY2 - stencilY)
	end

    local mouseY = self:getMouseY()
	self:updateSmoothScrolling()
	if mouseY ~= self:getMouseY() and self:isMouseOver() then
		self:onMouseMove(0, self:getMouseY() - mouseY)
	end
	self:updateTooltip()

    if #self.columns > 0 then
--		print(self:getScrollHeight())
        self:drawRectBorderStatic(0, 0 - self.itemheight, self.width, self.itemheight - 1, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b)
        self:drawRectStatic(0, 0 - self.itemheight - 1, self.width, self.itemheight-2,self.listHeaderColor.a,self.listHeaderColor.r, self.listHeaderColor.g, self.listHeaderColor.b)
        local dyText = (self.itemheight - FONT_HGT_SMALL) / 2
        for i,v in ipairs(self.columns) do
            self:drawRectStatic(v.size, 0 - self.itemheight, 1, self.itemheight + math.min(self.height, self.itemheight * #self.items - 1), 1, self.borderColor.r, self.borderColor.g, self.borderColor.b)
            if v.name then
                self:drawText(v.name, v.size + 10, 0 - self.itemheight - 1 + dyText - self:getYScroll(), 1,1,1,1,UIFont.Small)
            end
        end
    end
end

---@param name string
---@param item InventoryItem
function TilesScrollingListBox:insertIntoItemTab(name, item)
    for i=1, #self.items do
        local cItem = self.items[i]

        if cItem.text == name then
            for j=1, #cItem.item do
                local singleItem = cItem.item[j]
                if singleItem == item then return end
            end
			table.insert(cItem.item, item)
			return
        end
    end


	-- Couldn't add it, so let's add it as a new item
	self:addItem(name, {item})
end


return TilesScrollingListBox