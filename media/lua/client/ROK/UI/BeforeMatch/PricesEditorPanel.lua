local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
local ConfirmationPanel = require("ROK/UI/ConfirmationPanel")

---------------------------------------

local WIPE_PLAYER_ICON = getTexture("media/textures/BeforeMatchPanel/WipePlayer.png")     -- https://www.freepik.com/icon/close_14440874#fromView=family&page=1&position=0&uuid=e818dfad-684a-4567-9aca-43ed2667f4e1
local REFRESH_ICON = getTexture("media/textures/BeforeMatchPanel/Loop.png")               -- https://www.freepik.com/icon/rotated_14441036#fromView=family&page=1&position=3&uuid=135de5a3-1019-46dd-bbef-fdbb2fd5b027
local STARTER_KIT_ICON = getTexture("media/textures/BeforeMatchPanel/GiveStarterKit.png") -- https://www.freepik.com/icon/gift-box_12484717#fromView=family&page=1&position=4&uuid=6b0bb61f-b073-41c1-b474-32da7131c231

-------------------------------

---@class PricesEditorScrollingTable : ISPanel
---@field datas ISScrollingListBox
local PricesEditorScrollingTable = ISPanel:derive("PricesEditorScrollingTable")

---@param x number
---@param y number
---@param width number
---@param height number
---@param viewer any
---@return PricesEditorScrollingTable
function PricesEditorScrollingTable:new(x, y, width, height, viewer)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)

    o.listHeaderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.3 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.0 }
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    o.totalResult = 0
    o.viewer = viewer
    ---@cast o PricesEditorScrollingTable
    PricesEditorScrollingTable.instance = o
    return o
end

function PricesEditorScrollingTable:createChildren()
    -- local btnHgt = math.max(25, GenericUI.SMALL_FONT_HGT + 3 * 2)
    -- local bottomHgt = 5 + GenericUI.SMALL_FONT_HGT * 2 + 5 + btnHgt + 20 + GenericUI.LARGE_FONT_HGT + GenericUI.HEADER_HGT + GenericUI.ENTRY_HGT

    self.datas = ISScrollingListBox:new(0, GenericUI.HEADER_HGT, self.width, self.height - GenericUI.HEADER_HGT)
    self.datas:initialise()
    self.datas:instantiate()
    self.datas.itemheight = GenericUI.SMALL_FONT_HGT + 4 * 2
    self.datas.selected = 0
    self.datas.joypadParent = self
    self.datas.font = UIFont.NewSmall
    self.datas.doDrawItem = self.drawDatas
    self.datas.drawBorder = true
    self.datas:addColumn("FullType", 0)
    self.datas:addColumn("Tag", 200)
    self.datas:addColumn("Price", 450)
    self:addChild(self.datas)
end

---@param shopItemsTable shopItemsTable
function PricesEditorScrollingTable:initList(shopItemsTable)
    self.datas:clear()

    for itemFullType, shopItemElement in pairs(shopItemsTable.items) do
        if self.viewer.filterEntry:getInternalText() ~= "" and string.trim(self.viewer.filterEntry:getInternalText()) == nil or string.contains(string.lower(itemFullType), string.lower(string.trim(self.viewer.filterEntry:getInternalText()))) then
            self.datas:addItem(itemFullType, shopItemElement)
        end
    end
end

function PricesEditorScrollingTable:update()
    self.datas.doDrawItem = self.drawDatas
end

function PricesEditorScrollingTable:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end
    local a = 0.9

    --todo show tag in edit box
    -- todo show price in edit box
    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15)
    end

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.6, 0.5, 0.5)
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)

    local xOffset = 10
    self:drawText(item.text, xOffset, y + 4, 1, 1, 1, a, self.font)
    return y + self.itemheight
end

--************************************************************************--
-- TODO Make it Local
---@class PricesEditorPanel : ISCollapsableWindow
PricesEditorPanel = ISCollapsableWindow:derive("PricesEditorPanel")

function PricesEditorPanel.Open(x, y, width, height)
    if PricesEditorPanel.instance then
        PricesEditorPanel.instance:close()
    end

    local modal = PricesEditorPanel:new(x, y, width, height)
    modal:initialise()
    modal:addToUIManager()
    modal.instance:setKeyboardFocus()

    return modal
end

function PricesEditorPanel.Close()

    if PricesEditorPanel.instance then
        PricesEditorPanel.instance:close()
    end
end
function PricesEditorPanel:new(x, y, width, height)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 1 }
    o.width = width
    o.height = height
    o.resizable = false
    o.moveWithMouse = false
    PricesEditorPanel.instance = o
    return o
end

function PricesEditorPanel:createChildren()
    local xPadding = GenericUI.X_PADDING
    local yPadding = 10

    self.label = ISLabel:new(xPadding, yPadding, 25, getText("IGUI_EFT_AdminPanel_ManagePlayers"), 1, 1, 1, 1,
        UIFont.NewLarge, true)
    self.label:initialise()
    self.label:instantiate()
    self:addChild(self.label)

    -- TODO Clean this up

    local y = self.label:getBottom() + yPadding * 2
    local leftSideWidth = (self:getWidth() - xPadding * 2) / 1.25

    local entryHgt = GenericUI.SMALL_FONT_HGT + 2 * 2
    self.filterEntry = ISTextEntryBox:new("Players", 10, y, leftSideWidth, entryHgt)
    self.filterEntry:initialise()
    self.filterEntry:instantiate()
    self.filterEntry:setClearButton(true)
    self.filterEntry:setText("")
    self:addChild(self.filterEntry)

    ---@diagnostic disable-next-line: duplicate-set-field
    self.filterEntry.onTextChange = function()
        self:fillList()
    end

    y = y + self.filterEntry:getHeight() + yPadding
    local panelHeight = self:getHeight() - self.filterEntry:getBottom() - yPadding * 2

    self.panel = ISTabPanel:new(xPadding, y, leftSideWidth, panelHeight)
    self.panel:initialise()
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.panel.target = self
    self.panel.equalTabWidth = false
    self.panel.tabTransparency = 0
    self.panel.tabHeight = 0
    self:addChild(self.panel)

    self.mainCategory = PricesEditorScrollingTable:new(0, 0, leftSideWidth, panelHeight, self)
    self.mainCategory:initialise()
    self.panel:addView("Items", self.mainCategory)
    self.panel:activateView("Items")
    self:fillList()


    ---------------------------------
    -- Buttons

    local btnY = self.filterEntry:getY()
    local btnX = self.panel:getRight() + 10

    local btnWidth = (self:getWidth() - self.panel:getWidth()) - xPadding * 3
    local btnHeight = 64


    self.btnRefresh = ISButton:new(
        btnX, btnY, btnWidth, btnHeight,
        "", self, PricesEditorPanel.onClick
    )
    self.btnRefresh.internal = "REFRESH"
    self.btnRefresh:setImage(REFRESH_ICON)
    self.btnRefresh:setTooltip(getText("IGUI_EFT_AdminPanel_Refresh"))
    self.btnRefresh:initialise()
    self.btnRefresh:instantiate()
    self.btnRefresh.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self:addChild(self.btnRefresh)


    btnY = btnY + btnHeight + yPadding


    -- EDIT TAG
    self.comboTag = ISComboBox:new(btnX, btnY, btnWidth, btnHeight, self, self.onChangeTag)
    self.comboTag:initialise()
    self.comboTag:instantiate()
    self.comboTag:setAnchorLeft(false)
    self:addChild(self.comboTag)

    for i=1, #PZ_EFT_CONFIG.Shop.tags do
        self.comboTag:addOption(PZ_EFT_CONFIG.Shop.tags[i])
    end

    btnY = btnY + btnHeight + yPadding

    -- EDIT PRICE
    self.entryPrice = ISTextEntryBox:new("", btnX, btnY, btnWidth, btnHeight)
    self.entryPrice:initialise()
    self.entryPrice:instantiate()
    self.entryPrice:setClearButton(false)
    self.entryPrice.font = UIFont.Small
    self.entryPrice:setText("")
    self.entryPrice:setOnlyNumbers(true)
    self.entryPrice:setHasFrame(false)
	self.entryPrice:setAnchorTop(false)
    self.entryPrice:setAnchorBottom(true)
	self.entryPrice:setAnchorRight(true)
    self:addChild(self.entryPrice)

end

function PricesEditorPanel:fillList()
    -- TODO Request json from server
    --sendClientCommand(EFT_MODULES.Shop, 'TransmitShopItems', {})

    --debugPrint("Filling list")
    local shopItems = ClientData.Shop.GetShopItems()


    self.mainCategory:initList(shopItems)
end

function PricesEditorPanel:prerender()
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)
end

function PricesEditorPanel:onClick(button)
    local confY = self:getY() + self:getHeight() + 20

    if button.internal == 'REFRESH' then
        self:fillList()
    else
        ---@type IsoPlayer
        local selectedPlayer = self.mainCategory.datas.items[self.mainCategory.datas.selected].item
        local plID = selectedPlayer:getOnlineID()
        local plUsername = selectedPlayer:getUsername()

        if button.internal == 'STARTER_KIT' then
            local function OnConfirmGiveStarterKit()
                sendClientCommand(EFT_MODULES.Player, "RelayStarterKit", { playerID = plID })
                local text = getText("UI_EFT_Say_SentStarterKit", plUsername)
                getPlayer():Say(text)
            end

            local text = getText("IGUI_EFT_AdminPanel_Confirmation_StarterKit", plUsername)
            self.confirmationPanel = ConfirmationPanel.Open(text, self:getX(), confY, self, OnConfirmGiveStarterKit)
        elseif button.internal == 'WIPE_PLAYER' then
            local function OnConfirmWipePlayer()
                sendClientCommand(EFT_MODULES.Player, "ResetPlayer", { playerID = plID })
                local text = getText("UI_EFT_Say_WipePlayer", plUsername)
                getPlayer():Say(text)
            end

            local text = getText("IGUI_EFT_AdminPanel_Confirmation_WipePlayer", plUsername)
            self.confirmationPanel = ConfirmationPanel.Open(text, self:getX(), confY, self, OnConfirmWipePlayer)
        end
    end
end

function PricesEditorPanel:setKeyboardFocus()
    local view = self.panel:getActiveView()
    if not view then return end
    Core.UnfocusActiveTextEntryBox()
    --view.filterWidgetMap.Type:focus()
end

function PricesEditorPanel:update()
    ISCollapsableWindow.update(self)

    ---@type shopItemElement
    local selection = self.mainCategory.datas.selected

    -- TODO Send to combobox and price entry



end

function PricesEditorPanel:render()
    ISCollapsableWindow.render(self)

    if self.confirmationPanel then
        local confY = self:getY() + self:getHeight() + 20
        local confX = self:getX()
        self.confirmationPanel:setX(confX)
        self.confirmationPanel:setY(confY)
    end
end

function PricesEditorPanel:close()
    if self.confirmationPanel then
        self.confirmationPanel:close()
    end
    ISCollapsableWindow.close(self)
end

--return PricesEditorPanel
