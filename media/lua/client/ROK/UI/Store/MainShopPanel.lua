--[[
    3 tabs in total

    Essential items tab, with basic weapons, bandages, ammo, food, and water available for sale

    A daily tab, where each day, 10-20 random, mostly high-value items, would be available
    for sale. Junk items, like staples, or corkscrews could pop up in here, but it should
    primarily remain something players would need for their runs.

    A sell tab, where players can drag items in from their inventory and sell them
    for cash directly into their account balance.

    Visible balance from all three tabs (Maybe on top?), purchased items should be sent
    directly at the entrance of the safehouse (inside I guess). The box where items will
    be placed should have a limit of weight
]]

require "ISUI/ISCollapsableWindow"

-- TODO Add sellMultiplier
-- TODO Add filtering
local GenericUI = require("ROK/UI/GenericUI")
local ClientShopManager = require("ROK/Economy/ClientShopManager")
local ClientBankManager = require("ROK/Economy/ClientBankManager")
local CustomTabPanel = require("ROK/UI/Store/Components/CustomTabPanel")


local BuyPanel = require("ROK/UI/Store/Buy/BuyMainPanel")
local SellPanel = require("ROK/UI/Store/Sell/SellMainPanel")
------------------------------

---@class MainShopPanel : ISCollapsableWindow
---@field pcPosition coords
MainShopPanel = ISCollapsableWindow:derive("MainShopPanel")
MainShopPanel.bottomInfoHeight = GenericUI.SMALL_FONT_HGT * 4

---@param x any
---@param y any
---@param width any
---@param height any
---@param character IsoPlayer
---@param pcPosition coords
---@return MainShopPanel
function MainShopPanel:new(x, y, width, height, character, pcPosition)
    local o = {}
    if x == 0 and y == 0 then
        x = (getCore():getScreenWidth() / 2) - (width / 2)
        y = (getCore():getScreenHeight() / 2) - (height / 2)
    end
    o = ISCollapsableWindow:new(x, y, width, height)
    o.minimumWidth = 800
    o.minimumHeight = 600
    setmetatable(o, self)
    self.__index = self

    o.title = getText("IGUI_Shop_Title")
    self.__index = self
    o.character = character
    o.playerNum = character and character:getPlayerNum() or -1
    o.pcPosition = pcPosition
    o:setResizable(false)
    o.lineH = 10
    o.fgBar = { r = 0, g = 0.6, b = 0, a = 0.7 }
    o.craftInProgress = false
    o.selectedIndex = {}
    o:setWantKeyEvents(true)

    ---@type MainShopPanel
    return o
end


---@param player IsoPlayer
---@param pcPos coords
function MainShopPanel.Open(player, pcPos)
    MainShopPanel.instance = MainShopPanel:new(0, 0, 1200, 600, player, pcPos)
    MainShopPanel.instance:initialise()
    MainShopPanel.instance:addToUIManager()
    MainShopPanel.instance:setVisible(true)
    MainShopPanel.instance:setEnabled(true)
end

---Closes all the related tabs too
function MainShopPanel:close()
    self:removeFromUIManager()
    ISCollapsableWindow.close(self)
end

--**********************************************--

function MainShopPanel:initialise()
    ISCollapsableWindow.initialise(self)
    ClientBankManager.RequestBankAccountFromServer()
    self.accountBalance = ClientBankManager.GetPlayerBankAccountBalance()
end

function MainShopPanel:createChildren()
    ISCollapsableWindow.createChildren(self)
    local th = self:titleBarHeight()
    local rh = self.resizable and self:resizeWidgetHeight() or 0

    -- This only contains the tabs, not the entire thing.
    local mainPanelHeight = self.height - th - rh

    --* MAIN PANEL *--
    self.panel = CustomTabPanel:new(0, th, self.width, mainPanelHeight)
    self.panel:initialise()
    self.panel:setAnchorRight(true)
    self.panel:setAnchorBottom(true)
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.panel.onActivateView = MainShopPanel.onActivateView
    self.panel.tabHeight = 50

    self.panel.target = self
    self.panel:setEqualTabWidth(false)
    self:addChild(self.panel)


    --* BALANCE PANEL *--
    self.balancePanel = ISRichTextPanel:new(0, th + self.panel.tabHeight, self.width, 10)
    self.balancePanel.background = false
    self.balancePanel.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 }
    self.balancePanel.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.balancePanel:initialise()
    self:addChild(self.balancePanel)

    self.balancePanel:setText(getText("IGUI_Shop_CurrentBalance"))
    self.balancePanel:paginate()
    -------------------------
    self.categories = {}

    local addedHeight = self.balancePanel.height
    local catHeight = self.height - th - rh - addedHeight - 50

    --* ESSENTIAL ITEMS *--
    self.essentialItemsCat = BuyPanel:new(0, 0, self.width, catHeight, ClientShopManager.GetEssentialItems(), "ESSENTIAL")
    self.essentialItemsCat:initialise()
    self.panel:addView(getText("IGUI_Shop_TabEssential"), self.essentialItemsCat, self.width / 3 - 2, addedHeight)
    self.essentialItemsCat.category = 1
    table.insert(self.categories, self.essentialItemsCat)

    --* DAILY ITEMS *--
    self.dailyItemsCat = BuyPanel:new(0, 0, self.width, catHeight, ClientShopManager.GetDailyItems(), "DAILY")
    self.dailyItemsCat:initialise()
    self.panel:addView(getText("IGUI_Shop_TabDaily"), self.dailyItemsCat, self.width / 3 - 2, addedHeight)
    self.dailyItemsCat.category = 2
    table.insert(self.categories, self.dailyItemsCat)

    --* SELL MENU *--
    self.sellCat = SellPanel:new(0, 0, self.width, catHeight)
    self.sellCat:initialise()
    self.panel:addView(getText("IGUI_Shop_TabSell"), self.sellCat, self.width / 3 - 2, addedHeight)
    self.sellCat.category = 3
    table.insert(self.categories, self.sellCat)

    -- Set default stuff
    self.panel:activateView(getText("IGUI_Shop_TabEssential"))
end

function MainShopPanel:update()
    ISCollapsableWindow.update(self)
    self.accountBalance = ClientBankManager.GetPlayerBankAccountBalance()

    -- Check distance from computer
    if IsoUtils.DistanceTo(self.pcPosition.x, self.pcPosition.y, self.character:getX(), self.character:getY()) > 2 then
        self:close()
    end
end

function MainShopPanel:render()
    ISCollapsableWindow.render(self)
    if self.accountBalance == nil then return end
    local balanceText

    -- SP Workaround
    if isClient then
        balanceText = getText("IGUI_Shop_CurrentBalance", self.accountBalance)
    else
        balanceText = getText("IGUI_Shop_CurrentBalance", 1000)
    end
 
    self.balancePanel:setText(balanceText)
    self.balancePanel:paginate()
end

------------------------------------------------
--- Search for PC while in safehouse
---@param playerNum number
---@param context any
---@param worldObjects any
---@param test any
---@return boolean
local function AddShopMenu(playerNum, context, worldObjects, test)
    if test then return true end

    -- -- SP DEBUG THING
    -- if isClient() then
    --     if not SafehouseInstanceHandler.IsInSafehouse() then return true end

    -- end

    ---@type IsoObject
    local clickedObject = worldObjects[1]
    local moveableObject = ISMoveableSpriteProps.fromObject(clickedObject)
    local pcTileName = "Desktop Computer"

    if instanceof(clickedObject, "IsoObject") and moveableObject.name == pcTileName then
        local sq = clickedObject:getSquare()
        local coords = {x = sq:getX(), y = sq:getY()}
        local playerObj = getSpecificPlayer(playerNum)
        local isNear = IsoUtils.DistanceTo(coords.x, coords.y, playerObj:getX(), playerObj:getY()) < 2
        if isNear then
            context:addOption(getText("ContextMenu_EFT_OpenShop"), playerObj, MainShopPanel.Open, coords)

            context:addOption("InstaHeal ($2500)", playerObj, InstaHeal.Execute, coords)
        end
    end
    return false
end

-- For MP, we can access the menu ONLY from the admin panel
Events.OnFillWorldObjectContextMenu.Add(AddShopMenu)
