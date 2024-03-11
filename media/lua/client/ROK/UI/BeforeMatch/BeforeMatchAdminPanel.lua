local BaseAdminPanel = require("ROK/UI/BaseComponents/BaseAdminPanel")
local TimePanel = require("ROK/UI/TimePanel")
local ClientState = require("ROK/ClientState")

local GenericUI = require("ROK/UI/BaseComponents/GenericUI")

local MatchOptionsPanel = require("ROK/UI/BeforeMatch/MatchOptionsPanel")
local ManagePlayersPanel = require("ROK/UI/BeforeMatch/ManagePlayersPanel")
local ModManagementPanel = require("ROK/UI/BeforeMatch/ModManagementPanel")
local OtherOptionsPanel = require("ROK/UI/BeforeMatch/OtherOptionsPanel")

--------------------------------

---@class BeforeMatchAdminPanel : BaseAdminPanel
---@field availableInstancesAmount integer
local BeforeMatchAdminPanel = BaseAdminPanel:derive("BeforeMatchAdminPanel")
BeforeMatchAdminPanel.instance = nil


local MATCH_START_TEXT = getText("IGUI_EFT_AdminPanel_StartMatch")
local MATCH_STOP_TEXT = getText("IGUI_EFT_AdminPanel_Stop")
local AVAILABLE_INSTANCES_STR = getText("IGUI_EFT_AdminPanel_InstancesAvailable")

---@param x number
---@param y number
---@param width number
---@param height number
---@return BeforeMatchAdminPanel
function BeforeMatchAdminPanel:new(x, y, width, height)
    local o = BaseAdminPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    self.availableInstancesAmount = -1      -- init

    ---@cast o BeforeMatchAdminPanel

    BeforeMatchAdminPanel.instance = o
    return o
end

function BeforeMatchAdminPanel:createChildren()
    BaseAdminPanel.createChildren(self)

    -- Start from the bottom and og up form that
    local btnHeight = 25
    local xPadding = 15
    local yPadding = 10
    local y = self:getHeight() - btnHeight - yPadding
    local btnWidth = self:getWidth() - xPadding * 2

    self.btnToggleMatch = ISButton:new(xPadding, y, btnWidth, btnHeight, MATCH_START_TEXT, self, self.onClick)
    self.btnToggleMatch.internal = "START"
    self.btnToggleMatch:initialise()
    self:addChild(self.btnToggleMatch)

    y = y - btnHeight - yPadding * 2      -- More padding from this



    --* Main buttons, ordererd as a grid
    ----------------

    local gridBtnWidth = (btnWidth - xPadding)/2
    local xRightPadding = self:getWidth()/2 + xPadding/2

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

    self.btnOtherOption = ISButton:new(xRightPadding, y, gridBtnWidth, btnHeight, "", self, self.onClick)
    self.btnOtherOption.internal = "OPEN_OTHERS_OPTION"
    self.btnOtherOption:initialise()
    self.btnOtherOption:setEnable(true)
    self.btnOtherOption:setTitle(getText("IGUI_EFT_AdminPanel_OtherOptions"))
    self:addChild(self.btnOtherOption)


    --------------------
    -- INFO PANEL, TOP ONE

    local panelInfoHeight = self:getHeight()/4

    self.panelInfo = ISRichTextPanel:new(0, 20, self:getWidth(), panelInfoHeight)
    self.panelInfo.autosetheight = false
    self.panelInfo.background = true
    self.panelInfo.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 }
    self.panelInfo.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.panelInfo.marginTop = self.panelInfo:getHeight() / 2
    self.panelInfo:initialise()
    self.panelInfo:paginate()
    self:addChild(self.panelInfo)


    local labelWidth = self:getWidth()/2
    local labelHeight = self.panelInfo:getHeight()/2


    -- Top of the panelInfo
    self:createIsRichTextPanel("labelInstancesAvailable", "panelInfo", labelWidth/2, 0, labelWidth, labelHeight, labelHeight/4, AVAILABLE_INSTANCES_STR)
    -- Bottom of Panel Info
    self:createIsRichTextPanel("labelValInstancesAvailable", "panelInfo", labelWidth/2, labelHeight + yPadding, labelWidth, labelHeight, 0, "")

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
    if btn.internal == "OPEN_OTHERS_OPTION" then
        GenericUI.ToggleSidePanel(self, OtherOptionsPanel)
        return
    end


    -- BOTTOM PART
    if btn.internal == 'START' then
        ClientState.isStartingMatch = true
        btn.internal = "STOP"
        btn:setTitle(MATCH_STOP_TEXT)
        -- Start timer. Show it on screen
        sendClientCommand(EFT_MODULES.Match, "StartCountdown", { stopTime = PZ_EFT_CONFIG.Client.Match.startMatchTime })
        TimePanel.Open("Starting match in...")
    elseif btn.internal == "STOP" then
        ClientState.isStartingMatch = false
        btn.internal = "START"
        btn:setTitle(MATCH_START_TEXT)
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
    self.btnOtherOption:setEnable(not isStartingMatch)

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
