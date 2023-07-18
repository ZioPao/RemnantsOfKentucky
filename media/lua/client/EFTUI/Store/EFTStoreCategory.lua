--***********************************************************
--**                    ROBERT JOHNSON                     **
--***********************************************************

EFTStoreCategory = ISPanelJoypad:derive("EFTStoreCategory")
EFTStoreCategory.instance = nil
EFTStoreCategory.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
EFTStoreCategory.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()

---Initialise a category, giving an items table
---@param itemsTable table
function EFTStoreCategory:initialise(itemsTable)
    ISPanelJoypad.initialise(self)
    local fontHgtSmall = self.SMALL_FONT_HGT
    local entryHgt = fontHgtSmall + 2 * 2

    self.items = ISScrollingListBox:new(1, entryHgt + 25, self.width / 2, self.height - (entryHgt + 25))
    self.items:initialise()
    self.items:instantiate()
    self.items:setAnchorRight(false) -- resize in update()
    self.items:setAnchorBottom(true)
    self.items.itemHeight = 2 + self.MEDIUM_FONT_HGT + 32 + 4
    self.items.selected = 0
    self.items.doDrawItem = EFTStoreCategory.doDrawItem
    self.items.onMouseDown = EFTStoreCategory.onMouseDown
    self.items.onMouseDoubleClick = EFTStoreCategory.onDoubleClick
    self.items.joypadParent = self
    --    self.items.resetSelectionOnChangeFocus = true
    self.items.drawBorder = false
    self:addChild(self.items)

    self.items.SMALL_FONT_HGT = self.SMALL_FONT_HGT
    self.items.MEDIUM_FONT_HGT = self.MEDIUM_FONT_HGT


    for i = 1, #itemsTable do
        self.items:addItem(i, itemsTable[i])
    end


    self.buyPanel = BuyQuantityPanel:new(self.items:getRight() + 10, entryHgt + 25, self.width/2 - 20, self.height/2, nil)
    self.buyPanel:initialise()
    self:addChild(self.buyPanel)
    
    --self.filterLabel = ISLabel:new(4, 2, entryHgt, getText("IGUI_CraftUI_Name_Filter"),1,1,1,1,UIFont.Small, true)
    --self:addChild(self.filterLabel)

    --local width = ((self.width/3) - getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_CraftUI_Name_Filter"))) - 98
    -- self.filterEntry = ISTextEntryBox:new("", getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_CraftUI_Name_Filter")) + 9, 2, width, fontHgtSmall)
    -- self.filterEntry:initialise()
    -- self.filterEntry:instantiate()
    -- self.filterEntry:setText("")
    -- self.filterEntry:setClearButton(true)
    -- self:addChild(self.filterEntry)
    -- self.lastText = self.filterEntry:getInternalText()

    -- self.filterAll = ISTickBox:new(self.filterEntry.x + self.filterEntry.width + 5, 2, 20, entryHgt, "", self, self.onFilterAll)
    -- self.filterAll:initialise()
    -- self.filterAll:addOption(getText("IGUI_FilterAll"))
    -- self.filterAll:setWidthToFit()
    -- self:addChild(self.filterAll)
end

function EFTStoreCategory:update()
    if not self.parent:getIsVisible() then return end
    -- local text = string.trim(self.filterEntry:getInternalText())
    -- local filterAll = self.filterAll:isSelected(1)

    -- if (text ~= self.lastText) or (filterAll ~= self.filteringAll) then
    --     self.filteringAll = filterAll
    --     --self:filter()     TODO NO FILTERS
    --     self.lastText = text
    --     --self:syncAllFilters()
    -- end

    -- self.filterAll:setX(self.width / 3 - self.filterAll.width)
    -- self.filterEntry:setWidth(self.filterAll.x - 5 - self.filterEntry.x)
    -- self.items:setWidth(self.width / 3)
end

function EFTStoreCategory:prerender()
    self.items.backgroundColor.a = 0.8
    self.items.doDrawItem = EFTStoreCategory.doDrawItem
end

function EFTStoreCategory:filter()
    self.items:clear()
    self.items:setScrollHeight(0)
    local items = self.parent.recipesList[self.category]
    -- if self.filteringAll then
    --     items = self.parent.allRecipesList
    -- end
    if items == nil then
        return
    end
    --local filterText = string.trim(self.filterEntry:getInternalText())
    -- if filterText == "" then
    --     for i,item in ipairs(items) do
    --         self.items:addItem(i,item)
    --     end
    -- else
    --     filterText = string.lower(filterText)
    --     for i,item in ipairs(items) do
    --         if string.contains(string.lower(item.recipe:getName()), filterText) then
    --             self.items:addItem(i,item)
    --         end
    --     end
    -- end

    -- TODO Make this for items, not recipes

    table.sort(self.items.items, function(a, b)
        a = a.item
        b = b.item
        if a.available and not b.available then return true end
        if not a.available and b.available then return false end
        if a.customRecipeName and not b.customRecipeName then return true end
        if not a.customRecipeName and b.customRecipeName then return false end
        return not string.sort(a.recipe:getName(), b.recipe:getName())
    end)
end

function EFTStoreCategory:syncAllFilters()
    local text = self.filterEntry:getInternalText()
    local filterAll = self.filterAll:isSelected(1)
    for _, ui in ipairs(self.parent.categories) do
        if (ui ~= self) and (not ui:isVisible()) then
            if text ~= ui.filterEntry:getInternalText() then
                ui.filterEntry:setText(text)
            end
            if filterAll ~= ui.filterAll:isSelected(1) then
                ui.filterAll:setSelected(1, filterAll)
            end
        end
    end
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

    self:drawText(item.item:getName(), 6, y + 2, 1, 1, 1, a, UIFont.Medium)
    if item.item.customRecipeName then
        self:drawText(item.item.customRecipeName, 6, y + 2 + self.MEDIUM_FONT_HGT, 1, 1, 1, a, UIFont.Small)
    end

    local textWidth = 0
    local iconX = 100
    local iconSize = 50

    local icon = item.item:getIcon()
    if item.item:getIconsForTexture() and not item.item:getIconsForTexture():isEmpty() then
        icon = item.item:getIconsForTexture():get(0)
    end
    if icon then
        local texture = getTexture("Item_" .. icon)
        if texture then
            self:drawTextureScaledAspect2(texture, self:getWidth() - iconSize*2, y + (self.itemHeight - iconSize) / 2, iconSize, iconSize,  1, 1, 1, 1)
        end
    end
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

    local categoryUI = self.parent
    local favoriteStar = nil
    local favoriteAlpha = a
    if item.index == self.mouseoverselected and not self:isMouseOverScrollBar() then
        if self:getMouseX() >= categoryUI:getFavoriteX() then
            favoriteStar = item.item.favorite and categoryUI.favCheckedTex or categoryUI.favNotCheckedTex
            favoriteAlpha = 0.9
        else
            favoriteStar = item.item.favorite and categoryUI.favoriteStar or categoryUI.favNotCheckedTex
            favoriteAlpha = item.item.favorite and a or 0.3
        end
    elseif item.item.favorite then
        favoriteStar = categoryUI.favoriteStar
    end
    if favoriteStar then
        self:drawTexture(favoriteStar, categoryUI:getFavoriteX() + categoryUI.favPadX,
            y + (item.height / 2 - favoriteStar:getHeight() / 2), favoriteAlpha, 1, 1, 1)
    end

    return y + item.height
end

function EFTStoreCategory:getFavoriteX()
    -- scrollbar width=17 but only 13 pixels wide visually
    local scrollBarWid = self.items:isVScrollBarVisible() and 13 or 0
    return self.items:getWidth() - scrollBarWid - self.favPadX - self.favWidth - self.favPadX
end

function EFTStoreCategory:isMouseOverFavorite(x)
    return (x >= self:getFavoriteX()) and not self.items:isMouseOverScrollBar()
end

function EFTStoreCategory:onMouseDown(x, y)
    local row = self:rowAt(x, y)
    if row == -1 then return end
    if self.parent:isMouseOverFavorite(x) then
        self.parent:addToFavorite(false)
    elseif not self:isMouseOverScrollBar() then
        self.selected = row
    end
end

function EFTStoreCategory:addToFavorite(fromKeyboard)
    if self.items:size() == 0 then return end
    local selectedIndex = self.items:rowAt(self.items:getMouseX(), self.items:getMouseY())
    if fromKeyboard == true then
        selectedIndex = self.items.selected
    end
    local selectedItem = self.items.items[selectedIndex].item
    selectedItem.favorite = not selectedItem.favorite
    if self.character then
        self.character:getModData()[self.shopPanel:getFavoriteModDataString(selectedItem.recipe)] = selectedItem
        .favorite
    end
    self.shopPanel:refresh()
end

function EFTStoreCategory:onDoubleClick(x, y)
    local row = self:rowAt(x, y)
    if row == -1 then return end
    if x < self.parent:getFavoriteX() then
        --self.parent.parent:craft()
    elseif not self:isMouseOverScrollBar() then
        self.parent:addToFavorite(false)
    end
end

function EFTStoreCategory:new(x, y, width, height, shopPanel)
    local o = {}
    o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.shopPanel = shopPanel
    o.character = shopPanel.character
    o.favoriteStar = getTexture("media/ui/FavoriteStar.png")
    o.favCheckedTex = getTexture("media/ui/FavoriteStarChecked.png")
    o.favNotCheckedTex = getTexture("media/ui/FavoriteStarUnchecked.png")
    o.favPadX = 20
    o.favWidth = o.favoriteStar and o.favoriteStar:getWidth() or 13
    o:noBackground()
    EFTStoreCategory.instance = o
    return o
end
