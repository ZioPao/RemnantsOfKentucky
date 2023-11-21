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


-- TODO Add filtering
-- TODO add visible player balance
require "ISUI/ISCollapsableWindow"
-- TODO Add sellMultiplier

local CustomTabPanel = require("ROK/UI/Store/CustomTabPanel")
local StoreCategory = require("ROK/UI/Store/StoreCategory")
local SellPanel = require("ROK/UI/Store/SellPanel")
local GenericUI = require("ROK/UI/GenericUI")
local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")
local ClientShopManager = require("ROK/Economy/ClientShopManager")
local ClientBankManager = require("ROK/Economy/ClientBankManager")
------------------------------

---@class MainShopPanel : ISCollapsableWindow
MainShopPanel = ISCollapsableWindow:derive("MainShopPanel")
MainShopPanel.bottomInfoHeight = GenericUI.SMALL_FONT_HGT * 4

function MainShopPanel:new(x, y, width, height, character)
    local o = {}
    if x == 0 and y == 0 then
        x = (getCore():getScreenWidth() / 2) - (width / 2)
        y = (getCore():getScreenHeight() / 2) - (height / 2)
    end
    o = ISCollapsableWindow:new(x, y, width, height)
    o.minimumWidth = 800
    o.minimumHeight = 600
    setmetatable(o, self)

    o.title = getText("IGUI_Shop_Title")
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

---Closes all the related tabs too
function MainShopPanel:close()
    self.panel:close()
    self.essentialItemsCat:close()
    self.dailyItemsCat:close()
    self.sellCat:close()
    ISCollapsableWindow.close(self)
end

function MainShopPanel.Open()
    MainShopPanel.instance = MainShopPanel:new(0, 0, 800, 600, getPlayer())
    MainShopPanel.instance:initialise()
    MainShopPanel.instance:addToUIManager()
    MainShopPanel.instance:setVisible(true)
    MainShopPanel.instance:setEnabled(true)
end

-- Debug only
function MainShopPanel.ForceClose()
    MainShopPanel.instance:close()
end
--**********************************************--

function MainShopPanel:initialise()
    ISCollapsableWindow.initialise(self)
    ClientBankManager.RequestBankAccountFromServer()

    self.accountBalance = ClientBankManager.GetPlayerBankAccountBalance()
    -- Fetch bank account
    -- if self.accountBalance == nil then
    --     print("No bank account, setting it up now. Close and reopen the menu for now")
    -- else
    --     print("Bank account found")
    -- end
end

function MainShopPanel:createChildren()
    ISCollapsableWindow.createChildren(self)
    local th = self:titleBarHeight()
    local rh = self.resizable and self:resizeWidgetHeight() or 0

    --* MAIN PANEL *--
    self.panel = CustomTabPanel:new(0, th, self.width, self.height - th - rh)
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
    self.essentialItemsCat = StoreCategory:new(0, 0, self.width, catHeight, self)
    self.essentialItemsCat:initialise()
    self.essentialItemsCat:setAnchorRight(true)
    self.essentialItemsCat:setAnchorBottom(true)
    self.panel:addView(getText("IGUI_Shop_TabEssential"), self.essentialItemsCat, self.width / 3 - 2, addedHeight)
    self.essentialItemsCat:initialiseList(ClientShopManager.GetEssentialItems())
    self.essentialItemsCat.parent = self
    self.essentialItemsCat.category = 1
    table.insert(self.categories, self.essentialItemsCat)

    --* DAILY ITEMS *--
    self.dailyItemsCat = StoreCategory:new(0, 0, self.width, catHeight, self)
    self.dailyItemsCat:initialise()
    self.dailyItemsCat:setAnchorRight(true)
    self.dailyItemsCat:setAnchorBottom(true)
    self.panel:addView(getText("IGUI_Shop_TabDaily"), self.dailyItemsCat, self.width / 3 - 2, addedHeight)
    self.dailyItemsCat:initialiseList(ClientShopManager.GetDailyItems())
    self.dailyItemsCat.parent = self
    self.dailyItemsCat.category = 2
    table.insert(self.categories, self.dailyItemsCat)

    --* SELL MENU *--
    self.sellCat = SellPanel:new(0, 0, self.width, catHeight)
    self.sellCat:initialise()
    self.sellCat:setAnchorRight(true)
    self.sellCat:setAnchorBottom(true)
    self.panel:addView(getText("IGUI_Shop_TabSell"), self.sellCat, self.width / 3 - 2, addedHeight)
    self.sellCat.parent = self
    self.sellCat.category = 3
    table.insert(self.categories, self.sellCat)

    -- Set default stuff
    self.panel:activateView(getText("IGUI_Shop_TabEssential"))
end

function MainShopPanel:update()
    ISCollapsableWindow.update(self)

    self.accountBalance = ClientBankManager.GetPlayerBankAccountBalance()
end

function MainShopPanel:render()
    ISCollapsableWindow.render(self)
    if self.accountBalance == nil then return end

    local balanceText = getText("IGUI_Shop_CurrentBalance")
    if isClient() then balanceText = balanceText .. self.accountBalance end
    self.balancePanel:setText(balanceText)
    self.balancePanel:paginate()
end

------------------------------------------------
-- Search for PC while in safehouse

local function AddShopMenu(player, context, worldObjects, test)
    if test then return true end
    if not SafehouseInstanceHandler.IsInSafehouse() then return true end
    local clickedObject = worldObjects[1]
    local moveableObject = ISMoveableSpriteProps.fromObject(clickedObject)

    local pcTileName = "Desktop Computer"

    if instanceof(clickedObject, "IsoObject") and moveableObject.name == pcTileName then
        context:addOption("Open Shop", worldObjects, MainShopPanel.Open, player)
    end
end

-- For MP, we can access the menu ONLY from the admin panel
Events.OnFillWorldObjectContextMenu.Add(AddShopMenu)
