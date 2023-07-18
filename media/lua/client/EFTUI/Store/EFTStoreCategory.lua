local BuyQuantityPanel = require("EFTUI/Store/BuyQuantityPanel")

EFTStoreCategory = ISPanelJoypad:derive("EFTStoreCategory")
EFTStoreCategory.instance = nil
EFTStoreCategory.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
EFTStoreCategory.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()

function EFTStoreCategory:new(x, y, width, height, shopPanel)
    local o = {}
    o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.shopPanel = shopPanel
    o:noBackground()
    EFTStoreCategory.instance = o
    return o
end

function EFTStoreCategory:createChildren()
    local fontHgtSmall = self.SMALL_FONT_HGT
    local entryHgt = fontHgtSmall + 2 * 2

    self.items = ISScrollingListBox:new(1, entryHgt, self.width / 2, self.height - (entryHgt))
    self.items:initialise()
    self.items:instantiate()
    self.items:setAnchorRight(false) -- resize in update()
    self.items:setAnchorBottom(true)
    self.items.itemHeight = 2 + self.MEDIUM_FONT_HGT + 32 + 4
    self.items.selected = 0
    self.items.doDrawItem = EFTStoreCategory.doDrawItem
    self.items.onMouseDown = EFTStoreCategory.onMouseDownItems
    self.items.joypadParent = self
    self.items.drawBorder = false
    self:addChild(self.items)

    self.items.SMALL_FONT_HGT = self.SMALL_FONT_HGT
    self.items.MEDIUM_FONT_HGT = self.MEDIUM_FONT_HGT

    for i = 1, #self.itemsTable do
        self.items:addItem(i, self.itemsTable[i])
    end

    local buyPanelX = self.items:getRight() + 10
    local buyPanelY = entryHgt
    local buyPanelWidth = self.width / 2 - 20
    local buyPanelHeight = self.height - 20

    self.buyPanel = BuyQuantityPanel:new(buyPanelX, buyPanelY, buyPanelWidth, buyPanelHeight, self.shopPanel)
    self.buyPanel:initialise()
    self:addChild(self.buyPanel)
end

---Initialise a category, giving an items table
---@param itemsTable table
function EFTStoreCategory:initialise(itemsTable)
    ISPanelJoypad.initialise(self)

    self.itemsTable = itemsTable
 
end

function EFTStoreCategory:close()
    print("Closing EFTStoreCategory")
    self.buyPanel:removeFromUIManager()
    self.buyPanel:close()
    ISPanelJoypad.close(self)
end

function EFTStoreCategory:update()
    if not self.parent:getIsVisible() then return end
end

function EFTStoreCategory:prerender()
    self.items.backgroundColor.a = 0.8
    self.items.doDrawItem = EFTStoreCategory.doDrawItem
end

function EFTStoreCategory:doDrawItem(y, item, alt)
    local baseItemDY = 0

    if y + self:getYScroll() >= self.height then return y + item.height end
    if y + item.height + self:getYScroll() <= 0 then return y + item.height end

    local a = 0.9

    -- Border of single item
    self:drawRectBorder(0, (y), self:getWidth(), item.height - 1, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)
    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), item.height - 1, 0.3, 0.7, 0.35, 0.15)
    end


    -- Items are stored in a table that works as a container, let's unpack them here to make it more readable
    local inventoryItem = item.item.item
    local itemCost = item.item.cost


    --* ITEM NAME *--
    self:drawText(inventoryItem:getName(), 6, y + 2, 1, 1, 1, a, UIFont.Medium)

    --* ITEM COST *--
    self:drawText(itemCost .. " $", self:getWidth() - 100, y + 2, 1, 1, 1, a, UIFont.Medium)




    -- local itemTexture = item.item
    -- if itemTexture then
    --     local texWidth = itemTexture:getWidthOrig()
    --     local texHeight = itemTexture:getHeightOrig()
    --     if texWidth <= 32 and texHeight <= 32 then
    --         self:drawTexture(itemTexture, 6 + (32 - texWidth) / 2, y + 2 + self.MEDIUM_FONT_HGT + baseItemDY +
    --         (32 - texHeight) / 2, a, 1, 1, 1)
    --     else
    --         self:drawTextureScaledAspect(itemTexture, 6, y + 2 + self.MEDIUM_FONT_HGT + baseItemDY, 32, 32, a, 1, 1, 1)
    --     end
    --     -- local name = item.item.evolved and item.item.resultName or item.item.itemName
    --     -- self:drawText(name, texWidth + 20, y + 2 + self.MEDIUM_FONT_HGT + baseItemDY + (32 - self.SMALL_FONT_HGT) / 2 - 2, 1, 1, 1, a, UIFont.Small)
    -- end

    -- local categoryUI = self.parent
    -- local favoriteStar = nil
    -- local favoriteAlpha = a
    -- if item.index == self.mouseoverselected and not self:isMouseOverScrollBar() then
    --     if self:getMouseX() >= categoryUI:getFavoriteX() then
    --         favoriteStar = item.item.favorite and categoryUI.favCheckedTex or categoryUI.favNotCheckedTex
    --         favoriteAlpha = 0.9
    --     else
    --         favoriteStar = item.item.favorite and categoryUI.favoriteStar or categoryUI.favNotCheckedTex
    --         favoriteAlpha = item.item.favorite and a or 0.3
    --     end
    -- elseif item.item.favorite then
    --     favoriteStar = categoryUI.favoriteStar
    -- end
    -- if favoriteStar then
    --     self:drawTexture(favoriteStar, categoryUI:getFavoriteX() + categoryUI.favPadX,
    --         y + (item.height / 2 - favoriteStar:getHeight() / 2), favoriteAlpha, 1, 1, 1)
    -- end

    return y + item.height
end

function EFTStoreCategory:onMouseDownItems(x, y)
    if #self.items == 0 then return end
    local row = self:rowAt(x, y)

    if row > #self.items then
        row = #self.items
    end
    if row < 1 then
        row = 1
    end

    -- RJ: If you select the same item it unselect it
    --if self.selected == y then
    --if self.selected == y then
    --self.selected = -1;
    --return;
    --end

    getSoundManager():playUISound("UISelectListItem")

    self.selected = row

    if self.onmousedown then
        self.onmousedown(self.target, self.items[self.selected].item)
    end

    -- TODO Send data to the BuyQuantityPanel

    self.parent.buyPanel:setSelectedItem(self.items[self.selected].item)
end