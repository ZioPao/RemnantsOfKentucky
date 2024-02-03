local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
local ENTRY_HGT = FONT_HGT_MEDIUM + 2 * 2
local FONT_SCALE = FONT_HGT_SMALL / 16
if FONT_SCALE < 1 then
    FONT_SCALE = 1
end

-------------------------------

local ConfirmationPanel = require("ROK/UI/ConfirmationPanel")
-------------------------------

---@class ManagePlayersScrollingTable : ISPanel
---@field datas ISScrollingListBox
local ManagePlayersScrollingTable = ISPanel:derive("ManagePlayersScrollingTable")

---@param x any
---@param y any
---@param width any
---@param height any
---@param viewer any
---@return ManagePlayersScrollingTable
function ManagePlayersScrollingTable:new(x, y, width, height, viewer)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)

    o.listHeaderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.3 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.0 }
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    o.totalResult = 0
    o.viewer = viewer
    ---@cast o ManagePlayersScrollingTable
    ManagePlayersScrollingTable.instance = o
    return o
end

function ManagePlayersScrollingTable:createChildren()
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local bottomHgt = 5 + FONT_HGT_SMALL * 2 + 5 + btnHgt + 20 + FONT_HGT_LARGE + HEADER_HGT + ENTRY_HGT

    self.datas = ISScrollingListBox:new(0, HEADER_HGT, self.width, self.height - bottomHgt + 10)
    self.datas:initialise()
    self.datas:instantiate()
    self.datas.itemheight = FONT_HGT_SMALL + 4 * 2
    self.datas.selected = 0
    self.datas.joypadParent = self
    self.datas.font = UIFont.NewSmall
    self.datas.doDrawItem = self.drawDatas
    self.datas.drawBorder = true
    self.datas:addColumn("", 0)
    self:addChild(self.datas)
end

function ManagePlayersScrollingTable:initList(module)
    self.datas:clear()
    for i = 0, module:size() - 1 do
        local pl = module:get(i)
        local username = pl:getUsername()

        if self.viewer.filterEntry:getInternalText() ~= "" and string.trim(self.viewer.filterEntry:getInternalText()) == nil or string.contains(string.lower(username), string.lower(string.trim(self.viewer.filterEntry:getInternalText()))) then
            self.datas:addItem(username, pl)
        end
    end
end

function ManagePlayersScrollingTable:update()
    self.datas.doDrawItem = self.drawDatas
end

function ManagePlayersScrollingTable:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end
    local a = 0.9

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

---@class ManagePlayersPanel : ISCollapsableWindow
local ManagePlayersPanel = ISCollapsableWindow:derive("ManagePlayersPanel")

function ManagePlayersPanel.Open(x, y)
    if ManagePlayersPanel.instance then
        ManagePlayersPanel.instance:close()
    end

    local modal = ManagePlayersPanel:new(x, y, 350 * FONT_SCALE, 500)
    modal:initialise()
    modal:addToUIManager()
    modal.instance:setKeyboardFocus()

    return modal
end

function ManagePlayersPanel:new(x, y, width, height)
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
    ManagePlayersPanel.instance = o
    return o
end

function ManagePlayersPanel:initialise()
    local top = 40

    local entryHgt = FONT_HGT_SMALL + 2 * 2
    self.filterEntry = ISTextEntryBox:new("Players", 10, top, (self.width - 10 * 2) / 1.5, entryHgt)
    self.filterEntry:initialise()
    self.filterEntry:instantiate()
    self.filterEntry:setClearButton(true)
    self.filterEntry:setText("")
    self:addChild(self.filterEntry)

---@diagnostic disable-next-line: duplicate-set-field
    self.filterEntry.onTextChange = function()
        self:fillList()
    end

    self.panel = ISTabPanel:new(10, top + entryHgt + 10, (self.width - 10 * 2) / 1.5, self.height + top - 50)
    self.panel:initialise()
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.panel.target = self
    self.panel.equalTabWidth = false
    self.panel.tabTransparency = 0
    self.panel.tabHeight = 0
    self:addChild(self.panel)

    local btnY = self.panel:getHeight() / 2 - top
    local btnX = self.panel:getRight() + 10

    local btnSize = (self:getWidth() - self.panel:getWidth()) - 30 -- You must account for the padding, 10 and -20


    local openIco = getTexture("media/ui/openPanelIcon.png")        -- Document icons created by Freepik - Flaticon - Document
    local refreshListIco = getTexture("media/ui/refreshIcon.png")   -- Refresh icons created by Dave Gandy - Flaticon - Refresh
    local deleteDataIco = getTexture("media/ui/deleteDataIcon.png") -- www.flaticon.com/free-icons/delete Delete icons created by Kiranshastry - Flaticon

    -- Middle button
    self.btnWipePlayer = ISButton:new(btnX, btnY, btnSize, btnSize / 1.5,
        getText("IGUI_EFT_AdminPanel_WipePlayer"), self, ManagePlayersPanel.onClick)
    self.btnWipePlayer.internal = "WIPE_PLAYER"
    self.btnWipePlayer:setTooltip(getText("IGUI_EFT_AdminPanel_Tooltip_WipePlayer"))
    self.btnWipePlayer:setImage(openIco)
    self.btnWipePlayer.anchorTop = false
    self.btnWipePlayer.anchorBottom = true
    self.btnWipePlayer:initialise()
    self.btnWipePlayer:instantiate()
    self.btnWipePlayer.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self:addChild(self.btnWipePlayer)

    self.btnRefresh = ISButton:new(btnX, btnY - self.btnWipePlayer:getHeight() - 10, btnSize, btnSize / 1.5,
        getText("IGUI_EFT_AdminPanel_Refresh"), self, ManagePlayersPanel.onClick)
    self.btnRefresh.internal = "REFRESH"
    self.btnRefresh:setTooltip(getText("IGUI_EFT_AdminPanel_Refresh"))
    self.btnRefresh:setImage(refreshListIco)
    self.btnRefresh.anchorTop = false
    self.btnRefresh.anchorBottom = true
    self.btnRefresh:initialise()
    self.btnRefresh:instantiate()
    self.btnRefresh.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self:addChild(self.btnRefresh)

    self.btnStarterKit = ISButton:new(btnX, btnY + self.btnWipePlayer:getHeight() + 10, btnSize, btnSize / 1.5,
        getText("IGUI_EFT_AdminPanel_StarterKit"), self, ManagePlayersPanel.onClick)
    self.btnStarterKit.internal = "STARTER_KIT"
    self.btnStarterKit:setTooltip(getText("IGUI_EFT_AdminPanel_Tooltip_StarterKit"))
    self.btnStarterKit:setImage(deleteDataIco)
    self.btnStarterKit:setBorderRGBA(1, 1, 1, 1)
    self.btnStarterKit:setTextureRGBA(1, 1, 1, 1)
    self.btnStarterKit.anchorTop = false
    self.btnStarterKit.anchorBottom = true
    self.btnStarterKit:initialise()
    self.btnStarterKit:instantiate()
    self.btnStarterKit.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self:addChild(self.btnStarterKit)


    local xPadding = 20
    local normalBtnWidth = self:getWidth() - xPadding * 2
    local normalBtnHeight = 25

    self.btnWipeEverything = ISButton:new(xPadding, self:getHeight() - normalBtnHeight - 10, normalBtnWidth,
        normalBtnHeight / 1.2, getText("IGUI_EFT_AdminPanel_WipeEverything"), self, ManagePlayersPanel.onClick)
    self.btnWipeEverything.internal = "WIPE_EVERYTHING"
    self.btnWipeEverything:setTooltip(getText("IGUI_EFT_AdminPanel_Tooltip_WipeEverything"))
    self.btnWipeEverything:setImage(deleteDataIco)
    self.btnWipeEverything:setBorderRGBA(1, 1, 1, 1)
    self.btnWipeEverything:setTextureRGBA(1, 1, 1, 1)
    self.btnWipeEverything.anchorTop = false
    self.btnWipeEverything.anchorBottom = true
    self.btnWipeEverything:initialise()
    self.btnWipeEverything:instantiate()
    self.btnWipeEverything.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self:addChild(self.btnWipeEverything)


    self.mainCategory = ManagePlayersScrollingTable:new(0, 0, self.panel.width, self.panel.height, self)
    self.mainCategory:initialise()
    self.panel:addView("Players", self.mainCategory)
    self.panel:activateView("Players")
    self:fillList()
end

function ManagePlayersPanel:fillList()
    local players
    if isClient() then
        players = getOnlinePlayers()
    else
        players = ArrayList.new()
        players:add(getPlayer())
    end

    self.mainCategory:initList(players)
end

function ManagePlayersPanel:prerender()
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)
end

function ManagePlayersPanel:onClick(button)

    local confY = self:getY() + self:getHeight() + 20

    if button.internal == 'REFRESH' then
        self:fillList()
    elseif button.internal == 'WIPE_EVERYTHING' then
        local function OnConfirmWipeEverything()
            debugPrint("Wipe everything")
            -- FIXME Implement wiping everything
        end
        local text = getText("IGUI_EFT_AdminPanel_Confirmation_WipeEverything")
        self.confirmationPanel = ConfirmationPanel.Open(text, self:getX(), confY, self, OnConfirmWipeEverything)
    else
        ---@type IsoPlayer
        local selectedPlayer = self.mainCategory.datas.items[self.mainCategory.datas.selected].item
        local plID = selectedPlayer:getOnlineID()
        local plUsername = selectedPlayer:getUsername()

        if button.internal == 'STARTER_KIT' then
            local function OnConfirmGiveStarterKit()
                sendClientCommand(EFT_MODULES.Common, "RelayStarterKit", {playerID = plID})
                local text = getText("UI_EFT_Say_SentStarterKit", plUsername)
                getPlayer():Say(text)
            end

            local text = getText("IGUI_EFT_AdminPanel_Confirmation_StarterKit", plUsername)
            self.confirmationPanel = ConfirmationPanel.Open(text, self:getX(), confY, self, OnConfirmGiveStarterKit)
        elseif button.internal == 'WIPE_PLAYER' then
            local function OnConfirmWipePlayer()
                sendClientCommand(EFT_MODULES.Safehouse, "ResetSafehouseAllocation", {playerID = plID})
                local text = getText("UI_EFT_Say_WipePlayer", plUsername)
                getPlayer():Say(text)
            end

            local text = getText("IGUI_EFT_AdminPanel_Confirmation_WipePlayer", plUsername)
            self.confirmationPanel = ConfirmationPanel.Open(text, self:getX(), confY, self, OnConfirmWipePlayer)
        end
    end
end

function ManagePlayersPanel:setKeyboardFocus()
    local view = self.panel:getActiveView()
    if not view then return end
    Core.UnfocusActiveTextEntryBox()
    --view.filterWidgetMap.Type:focus()
end

function ManagePlayersPanel:update()
    ISCollapsableWindow.update(self)
    local selection = self.mainCategory.datas.selected

    self.btnWipePlayer:setEnable(selection ~= 0)
    self.btnStarterKit:setEnable(selection ~= 0)
end

function ManagePlayersPanel:render()
    ISCollapsableWindow.render(self)

    if self.confirmationPanel then
        local confY = self:getY() + self:getHeight() + 20
        local confX = self:getX()
        self.confirmationPanel:setX(confX)
        self.confirmationPanel:setY(confY)
    end
end

function ManagePlayersPanel:close()
    if self.confirmationPanel then
        self.confirmationPanel:close()
    end
    ISCollapsableWindow.close(self)
end





return ManagePlayersPanel