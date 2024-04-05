local BaseAdminPanel = require("ROK/UI/BaseComponents/BaseAdminPanel")
local TimePanel = require("ROK/UI/TimePanel")
local ClientState = require("ROK/ClientState")

local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
local IconButton = require("ROK/UI/BaseComponents/IconButton")

local MatchOptionsPanel = require("ROK/UI/BaseComponents/MatchOptionsPanel")
local ManagePlayersPanel = require("ROK/UI/BeforeMatch/ManagePlayersPanel")
local ModManagementPanel = require("ROK/UI/BeforeMatch/ModManagementPanel")
local PricesEditorPanel = require("ROK/UI/BeforeMatch/PricesEditorPanel")


--------------------------------
local START_MATCH_TEXT = getText("IGUI_EFT_AdminPanel_StartMatch")
local STOP_MATCH_TEXT = getText("IGUI_EFT_AdminPanel_Stop")
local AVAILABLE_INSTANCES_STR = getText("IGUI_EFT_AdminPanel_InstancesAvailable")


local START_MATCH_ICON = getTexture("media/textures/BeforeMatchPanel/StartMatch.png") -- https://www.freepik.com/icon/play_14441317#fromView=family&page=1&position=0&uuid=6c560048-e143-4f62-bae1-92319409fae7
local STOP_MATCH_ICON = getTexture("media/textures/BeforeMatchPanel/StopMatch.png")   -- https://www.freepik.com/icon/stop_13570077#fromView=family&page=1&position=2&uuid=6db48743-461d-4009-a1be-79aba60b71a3

--------------------------------

---@class BeforeMatchAdminPanel : BaseAdminPanel
---@field availableInstancesAmount integer
local BeforeMatchAdminPanel = BaseAdminPanel:derive("BeforeMatchAdminPanel")
BeforeMatchAdminPanel.instance = nil




---@param x number
---@param y number
---@param width number
---@param height number
---@return BeforeMatchAdminPanel
function BeforeMatchAdminPanel:new(x, y, width, height)
    local o = BaseAdminPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    self.availableInstancesAmount = -1 -- init

    ---@cast o BeforeMatchAdminPanel

    BeforeMatchAdminPanel.instance = o
    return o
end

function BeforeMatchAdminPanel:createChildren()
    BaseAdminPanel.createChildren(self)

    -- Start from the bottom and og up form that
    local btnHeight = 50
    local xPadding = GenericUI.X_PADDING
    local yPadding = 10
    local y = self:getHeight() - btnHeight - yPadding
    local btnWidth = self:getWidth() - xPadding * 2

    self.btnToggleMatch = IconButton:new(
        xPadding, y, btnWidth, btnHeight,
        START_MATCH_ICON, START_MATCH_TEXT, "START",
        self, self.onClick
    )
    self.btnToggleMatch:initialise()
    self:addChild(self.btnToggleMatch)

    y = y - btnHeight - yPadding * 3 -- More padding from this



    --* Main buttons, ordererd as a grid
    ----------------

    local gridBtnWidth = (btnWidth - xPadding) / 2
    local xRightPadding = self:getWidth() / 2 + xPadding / 2

    -- Top line

    self.btnMatchOptions = ISButton:new(xPadding, y, gridBtnWidth, btnHeight, "", self, self.onClick)
    self.btnMatchOptions.internal = "OPEN_MATCH_OPTIONS"
    self.btnMatchOptions:initialise()
    self.btnMatchOptions:setEnable(true)
    self.btnMatchOptions:setTitle(getText("IGUI_EFT_AdminPanel_MatchOptions"))
    self:addChild(self.btnMatchOptions)

    self.btnManagePlayersOption = ISButton:new(xRightPadding, y, gridBtnWidth, btnHeight, "", self, self.onClick)
    self.btnManagePlayersOption.internal = "OPEN_PLAYERS_OPTIONS"
    self.btnManagePlayersOption:initialise()
    self.btnManagePlayersOption:setEnable(true)
    self.btnManagePlayersOption:setTitle(getText("IGUI_EFT_AdminPanel_ManagePlayers"))
    self:addChild(self.btnManagePlayersOption)

    y = y - btnHeight - yPadding

    -- Bottom Line
    self.btnManagementOption = ISButton:new(xPadding, y, gridBtnWidth, btnHeight, "", self, self.onClick)
    self.btnManagementOption.internal = "OPEN_MANAGEMENT_OPTION"
    self.btnManagementOption:initialise()
    self.btnManagementOption:setEnable(true)
    self.btnManagementOption:setTitle(getText("IGUI_EFT_AdminPanel_ModManagement"))
    self:addChild(self.btnManagementOption)

    self.btnEconomyManagement = ISButton:new(xRightPadding, y, gridBtnWidth, btnHeight, "", self, self.onClick)
    self.btnEconomyManagement.internal = "OPEN_ECONOMY_MANAGEMENT"
    self.btnEconomyManagement:initialise()
    self.btnEconomyManagement:setEnable(true)
    self.btnEconomyManagement:setTitle(getText("IGUI_EFT_AdminPanel_Economy"))
    self:addChild(self.btnEconomyManagement)


    --------------------
    -- INFO PANEL, TOP ONE

    local panelInfoHeight = self:getHeight() / 4

    self.panelInfo = ISRichTextPanel:new(0, 20, self:getWidth(), panelInfoHeight)
    self.panelInfo.autosetheight = false
    self.panelInfo.background = true
    self.panelInfo.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 }
    self.panelInfo.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.panelInfo.marginTop = self.panelInfo:getHeight() / 2
    self.panelInfo:initialise()
    self.panelInfo:paginate()
    self:addChild(self.panelInfo)


    local labelWidth = self:getWidth() / 2
    local labelHeight = self.panelInfo:getHeight() / 2


    -- Top of the panelInfo
    self:createIsRichTextPanel("labelInstancesAvailable", "panelInfo", labelWidth / 2, 0, labelWidth, labelHeight,
        labelHeight / 4, AVAILABLE_INSTANCES_STR)
    -- Bottom of Panel Info
    self:createIsRichTextPanel("labelValInstancesAvailable", "panelInfo", labelWidth / 2, labelHeight + yPadding,
        labelWidth, labelHeight, 0, "")
end

function BeforeMatchAdminPanel:onClick(btn)
    --*Match options
    if btn.internal == "OPEN_MATCH_OPTIONS" then
        GenericUI.ToggleSidePanel(self, MatchOptionsPanel)
        return
    end


    --* Players Options
    if btn.internal == "OPEN_PLAYERS_OPTIONS" then
        GenericUI.ToggleSidePanel(self, ManagePlayersPanel)
        return
    end

    --* Mod management Options
    if btn.internal == "OPEN_MANAGEMENT_OPTION" then
        GenericUI.ToggleSidePanel(self, ModManagementPanel)
        return
    end

    --* Other Options
    if btn.internal == "OPEN_ECONOMY_MANAGEMENT" then
        GenericUI.ToggleSidePanel(self, PricesEditorPanel)
        return
    end


    -- BOTTOM PART
    if btn.internal == 'START' then
        ClientState.SetIsStartingMatch(true)
        btn.internal = "STOP"
        btn.parent:setTexture(STOP_MATCH_ICON)
        btn:setTitle(STOP_MATCH_TEXT) -- Start timer. Show it on screen
        sendClientCommand(EFT_MODULES.Match, "StartCountdown", { stopTime = PZ_EFT_CONFIG.Client.Match.startMatchTime })
        --TimePanel.Open("")
    elseif btn.internal == "STOP" then
        ClientState.SetIsStartingMatch(false)
        btn.internal = "START"
        btn.parent:setTexture(START_MATCH_ICON)
        btn:setTitle(START_MATCH_TEXT)
        sendClientCommand(EFT_MODULES.Match, "StopCountdown", {})
        TimePanel.Close()
    end
end

function BeforeMatchAdminPanel:update()
    BaseAdminPanel.update(self)

    -- Top Panel
    local valInstancesAvailableText = " <CENTRE> " .. tostring(self.availableInstancesAmount)
    self.labelValInstancesAvailable:setText(valInstancesAvailableText)
    self.labelValInstancesAvailable.textDirty = true

    -- Buttons

    self.btnToggleMatch:setEnable(self.availableInstancesAmount > 0 and not ClientState.GetIsAutomaticStart())

    -- When starting the match, we'll disable various buttons
    local isStartingMatch = ClientState.GetIsStartingMatch()

    self.closeButton:setEnable(not isStartingMatch)
    self.btnMatchOptions:setEnable(not isStartingMatch)
    self.btnManagePlayersOption:setEnable(not isStartingMatch)
    self.btnManagementOption:setEnable(not isStartingMatch)
    self.btnEconomyManagement:setEnable(not isStartingMatch)
end

---@param amount integer
function BeforeMatchAdminPanel:setAvailableInstancesAmount(amount)
    self.availableInstancesAmount = amount
end

function BeforeMatchAdminPanel:setAvailableInstancesText(text)
    local valInstancesAvailableText = " <CENTRE> " .. tostring(text)
    self.labelValInstancesAvailable:setText(valInstancesAvailableText)
    self.labelValInstancesAvailable.textDirty = true
end

function BeforeMatchAdminPanel:render()
    BaseAdminPanel.render(self)
    if self.openedPanel then
        self.openedPanel:setX(self:getRight())
        self.openedPanel:setY(self:getBottom() - self:getHeight())
    end
end

function BeforeMatchAdminPanel:close()
    if self.openedPanel then
        self.openedPanel:close()
    end

    ISCollapsableWindow.close(self)
end

--*****************************************--
---@return ISCollapsableWindow?
function BeforeMatchAdminPanel.OnOpenPanel()
    sendClientCommand(EFT_MODULES.PvpInstances, "GetAmountAvailableInstances", {})
    sendClientCommand(EFT_MODULES.Match, "CheckIsAutomaticStart", {})

    return BaseAdminPanel.OnOpenPanel(BeforeMatchAdminPanel)
end

---Check if there's a panel already open, and closes it
---@return boolean
function BeforeMatchAdminPanel.OnClosePanel()
    return BaseAdminPanel.OnClosePanel(BeforeMatchAdminPanel)
end

return BeforeMatchAdminPanel
