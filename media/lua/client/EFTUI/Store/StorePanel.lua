-- 3 Tabs

-- Essential items tab, with basic weapons, bandages, ammo, food, and water available for sale
-- A daily tab, where each day, 10-20 random, mostly high-value items, would be available for sale. Junk items, like staples, or corkscrews could pop up in here, but it should primarily remain something players would need for their runs.
-- A sell tab, where players can drag items in from their inventory and sell them for cash directly into their account balance.

-- Visible balance from all three tabs (Maybe on top?), purchased items should be sent directly at the entrance of the safehouse (inside I guess)
-- The box where items will be placed has a limit of weight

require "ISUI/ISCollapsableWindow"

ShopPanel = ISCollapsableWindow:derive("ShopPanel")
ShopPanel.instance = nil
ShopPanel.largeFontHeight = getTextManager():getFontHeight(UIFont.Large)
ShopPanel.mediumFontHeight = getTextManager():getFontHeight(UIFont.Medium)
ShopPanel.smallFontHeight = getTextManager():getFontHeight(UIFont.Small)
ShopPanel.bottomInfoHeight = ShopPanel.smallFontHeight * 2


function ShopPanel.Open()
    ShopPanel.instance = ShopPanel:new(0, 0, 800, 600, getPlayer())
    ShopPanel.instance:initialise()
    ShopPanel.instance:addToUIManager()
    ShopPanel.instance:setVisible(true)
    ShopPanel.instance:setEnabled(true)
end

function ShopPanel:new(x, y, width, height, character)
    local o = {}
    if x == 0 and y == 0 then
        x = (getCore():getScreenWidth() / 2) - (width / 2)
        y = (getCore():getScreenHeight() / 2) - (height / 2)
    end
    o = ISCollapsableWindow:new(x, y, width, height)
    o.minimumWidth = 800
    o.minimumHeight = 600
    setmetatable(o, self)
    if getCore():getKey("Forward") ~= 44 then -- hack, seriously, need a way to detect qwert/azerty keyboard :(
        ShopPanel.qwertyConfiguration = false
    end

    o.LabelDash = "-"
    o.LabelDashWidth = getTextManager():MeasureStringX(UIFont.Small, o.LabelDash)

    o.title = "Shop"
    self.__index = self
    o.character = character
    o.playerNum = character and character:getPlayerNum() or -1
    o:setResizable(false)
    o.lineH = 10
    o.fgBar = { r = 0, g = 0.6, b = 0, a = 0.7 }
    o.craftInProgress = false
    o.selectedIndex = {}
    o:setWantKeyEvents(true)
    return o
end

function ShopPanel:close()
    -- Closes tabs

    print("Closing ShopPanel")
    self.panel:close()

    ISCollapsableWindow.close(self)
end

--**********************************************--
---Returns a table containing the essential items
---@return table
local function FetchEssentialItems()
    -- TODO Only for test
    local items = getAllItems()
    local essentialItems = {}

    for i = 0, 25 do
        essentialItems[i] = items:get(i)
        --tab.items:addItem(i, items:get(i))
    end

    return essentialItems
end

---Returns a table containing the daily items. TODO get them from the server?
---@return table
local function FetchDailyItems()
    return {}
end

function ShopPanel:initialise()
    ISCollapsableWindow.initialise(self)

    -- TODO Essential items list should be fixed
    -- self.essentialitems = FetchEssentialItems()
    -- self.dailyItems = FetchDailyItems()


    -- TODO Daily items should be randomly generated, based on server?


    -- TODO Sellable items must be present in a list
end

function ShopPanel:createChildren()
    ISCollapsableWindow.createChildren(self)
    local th = self:titleBarHeight()
    local rh = self.resizable and self:resizeWidgetHeight() or 0
    self.panel = EFTTabPanel:new(0, th, self.width, self.height - th - rh - ShopPanel.bottomInfoHeight)
    self.panel:initialise()
    self.panel:setAnchorRight(true)
    self.panel:setAnchorBottom(true)
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.panel.onActivateView = ShopPanel.onActivateView
    self.panel.tabHeight = 50

    self.panel.target = self
    self.panel:setEqualTabWidth(false)
    self:addChild(self.panel)

    self.categories = {}


    --* ESSENTIAL ITEMS *--
    local essentialItemsCat = EFTStoreCategory:new(0, 0, self.width, self.panel.height - self.panel.tabHeight, self)
    essentialItemsCat:initialise(FetchEssentialItems())
    essentialItemsCat:setAnchorRight(true)
    essentialItemsCat:setAnchorBottom(true)
    -- TODO Add items to the essential items scrolling list
    self.panel:addView("Essential Items", essentialItemsCat, self.width / 3 - 2)
    essentialItemsCat.parent = self
    essentialItemsCat.category = 1
    table.insert(self.categories, essentialItemsCat)

    --* DAILY ITEMS *--
    local dailyItemsCat = EFTStoreCategory:new(0, 0, self.width, self.panel.height - self.panel.tabHeight, self)
    dailyItemsCat:initialise(FetchDailyItems())
    dailyItemsCat:setAnchorRight(true)
    dailyItemsCat:setAnchorBottom(true)
    -- TODO Add items to the daily items scrolling list
    self.panel:addView("Daily Items", dailyItemsCat, self.width / 3 - 2)
    dailyItemsCat.parent = self
    dailyItemsCat.category = 2
    table.insert(self.categories, dailyItemsCat)


    --* SELL MENU *--
    local sellCat = SellPanel:new(0, 0, self.width, self.panel.height - self.panel.tabHeight)
    sellCat:initialise()
    sellCat:setAnchorRight(true)
    sellCat:setAnchorBottom(true)
    self.panel:addView("Sell Items", sellCat, self.width / 3 - 2)
    sellCat.parent = self
    sellCat.category = 3
    table.insert(self.categories, sellCat)


    -- self.essentialItems = {1,2,3,4}
    -- self.dailyItems = {}

    -- for i = 1, #self.essentialItems do

    --     local essentialItem = self.essentialItems[i]
    --     local cat = EFTStoreCategory:new(0, 0, self.width, self.panel.height - self.panel.tabHeight, self)
    --     cat:initialise()
    --     cat:setAnchorRight(true)
    --     cat:setAnchorBottom(true)
    --     local catName =  "Test" .. tostring(essentialItem)
    --     self.panel:addView(catName, cat)
    --     cat.infoText = getText("UI_CraftingUI")
    --     cat.parent = self
    --     cat.category = i

    --     table.insert(self.categories, cat)

    -- end

    -- self.itemsListBox = ISScrollingListBox:new(1, 30, self.width / 3, self.height - (59 + ShopPanel.bottomInfoHeight))
    -- self.itemsListBox:initialise()
    -- self.itemsListBox:instantiate()
    -- self.itemsListBox.itemheight = math.max(ShopPanel.smallFontHeight, 22)
    -- self.itemsListBox.font = UIFont.NewSmall
    -- self.itemsListBox.doDrawItem = self.drawItems
    -- self.itemsListBox.drawBorder = true
    -- self.itemsListBox:setVisible(false)
    -- self:addChild(self.itemsListBox)

    -- for k = 1, #self.recipesListH, 1 do
    --     local i = self.recipesListH[k]
    --     local l = self.recipesList[i]
    --     --for i,l in pairs(self.recipesList) do
    --     local cat1 = EFTStoreCategory:new(0, 0, self.width, self.panel.height - self.panel.tabHeight, self)
    --     cat1:initialise()
    --     cat1:setAnchorRight(true)
    --     cat1:setAnchorBottom(true)
    --     local catName = getTextOrNull("IGUI_CraftCategory_" .. i) or i
    --     self.panel:addView(catName, cat1)
    --     cat1.infoText = getText("UI_CraftingUI")
    --     cat1.parent = self
    --     cat1.category = i
    --     for s, d in ipairs(l) do
    --         cat1.recipes:addItem(s, d)
    --     end
    --     table.insert(self.categories, cat1)
    -- end

    -- self.craftOneButton = ISButton:new(0, self.height - ShopPanel.bottomInfoHeight - 20 - 15, 50, 25,
    --     getText("IGUI_CraftUI_ButtonCraftOne"), self, ShopPanel.craft)
    -- self.craftOneButton:initialise()
    -- self:addChild(self.craftOneButton)

    -- self.craftAllButton = ISButton:new(0, self.height - ShopPanel.bottomInfoHeight - 20 - 15, 50, 25,
    --     getText("IGUI_CraftUI_ButtonCraftAll"), self, ShopPanel.craftAll)
    -- self.craftAllButton:initialise()
    -- self:addChild(self.craftAllButton)


    -- self.taskLabel = ISLabel:new(4, 5, 19, "", 1, 1, 1, 1, UIFont.Small, true)
    -- self:addChild(self.taskLabel)

    -- self.addIngredientButton = ISButton:new(0, self.height - ShopPanel.bottomInfoHeight - 20 - 15, 50, 25,
    --     getText("IGUI_CraftUI_ButtonAddIngredient"), self, ShopPanel.onAddIngredient)
    -- self.addIngredientButton:initialise()
    -- self:addChild(self.addIngredientButton)
    -- self.addIngredientButton:setVisible(false)

    -- --    self.tickBox = ISTickBox:new(0, 0, 100, 20, "", self, ShopPanel.tickBoxChange)
    -- --    self.tickBox.onlyOnePossibility = true
    -- --    self.tickBox.choicesColor = {r=1, g=1, b=1, a=1}
    -- --    self.tickBox:initialise()
    -- --    self:addChild(self.tickBox)

    -- -- For non-evolved recipes
    -- self.ingredientPanel = ISScrollingListBox:new(1, 30, self.width / 3, self.height - (59 + ShopPanel.bottomInfoHeight))
    -- self.ingredientPanel:initialise()
    -- self.ingredientPanel:instantiate()
    -- self.ingredientPanel.itemheight = math.max(ShopPanel.smallFontHeight, 22)
    -- self.ingredientPanel.font = UIFont.NewSmall
    -- self.ingredientPanel.doDrawItem = self.drawNonEvolvedIngredient
    -- self.ingredientPanel.drawBorder = true
    -- self.ingredientPanel:setVisible(false)
    -- self:addChild(self.ingredientPanel)

    -- -- For evolved recipes
    -- self.ingredientListbox = ISScrollingListBox:new(1, 30, self.width / 3,
    --     self.height - (59 + ShopPanel.bottomInfoHeight))
    -- self.ingredientListbox:initialise()
    -- self.ingredientListbox:instantiate()
    -- self.ingredientListbox.itemheight = math.max(ShopPanel.smallFontHeight, 22)
    -- self.ingredientListbox.selected = 0
    -- self.ingredientListbox.joypadParent = self
    -- self.ingredientListbox.font = UIFont.NewSmall
    -- self.ingredientListbox.doDrawItem = self.drawEvolvedIngredient
    -- self.ingredientListbox:setOnMouseDoubleClick(self, self.onDblClickIngredientListbox)
    -- self.ingredientListbox.drawBorder = true
    -- self.ingredientListbox:setVisible(false)
    -- --    self.ingredientListbox.resetSelectionOnChangeFocus = true
    -- self:addChild(self.ingredientListbox)
    -- self.ingredientListbox.PoisonTexture = self.PoisonTexture

    -- self.noteRichText = ISRichTextLayout:new(self.width)
    -- self.noteRichText:setMargins(0, 0, 0, 0)
    -- self.noteRichText:setText(getText("IGUI_CraftUI_Note"))
    -- self.noteRichText.textDirty = true

    -- self.keysRichText = ISRichTextLayout:new(self.width)
    -- self.keysRichText:setMargins(5, 0, 5, 0)

    --self:refresh()
end

---Logic based on ISCraftingUI
function ShopPanel:refresh()
    local selectedView = self.panel.activeView.name
    self.panel:activateView(selectedView)
end
