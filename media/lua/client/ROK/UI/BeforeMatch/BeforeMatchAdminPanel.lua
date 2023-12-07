local BaseAdminPanel = require("ROK/UI/BaseAdminPanel")
local ManagePlayersPanel = require("ROK/UI/BeforeMatch/ManagePlayersPanel")
local TimePanel = require("ROK/UI/TimePanel")
local ClientState = require("ROK/ClientState")
--------------------------------

---@class BeforeMatchAdminPanel : BaseAdminPanel
local BeforeMatchAdminPanel = BaseAdminPanel:derive("BeforeMatchAdminPanel")
BeforeMatchAdminPanel.instance = nil


local MATCH_START_TEXT = getText("IGUI_EFT_AdminPanel_StartMatch")
local MATCH_STOP_TEXT = getText("IGUI_EFT_AdminPanel_Stop")
local AVAILABLE_INSTANCES_STR = getText("IGUI_EFT_AdminPanel_InstancesAvailable")
local ASSIGNED_SAFEHOUSES_STR = getText("IGUI_EFT_AdminPanel_SafehousesAssigned")



---@param x number
---@param y number
---@param width number
---@param height number
---@return BeforeMatchAdminPanel
function BeforeMatchAdminPanel:new(x, y, width, height)
    local o = BaseAdminPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    ---@cast o BeforeMatchAdminPanel

    BeforeMatchAdminPanel.instance = o
    return o
end

function BeforeMatchAdminPanel:createChildren()
    BaseAdminPanel.createChildren(self)

    -- Start from the bottom and og up form that
    local btnHeight = 25
    local xPadding = 20
    local yPadding = 10
    local y = self:getHeight() - btnHeight - yPadding
    local btnWidth = self:getWidth() - xPadding * 2

    self.btnToggleMatch = ISButton:new(xPadding, y, btnWidth, btnHeight, MATCH_START_TEXT, self, self.onClick)
    self.btnToggleMatch.internal = "START"
    self.btnToggleMatch:initialise()
    self:addChild(self.btnToggleMatch)

    y = y - btnHeight - yPadding * 1.5      -- More padding from this
    self.btnManagePlayers = ISButton:new(xPadding, y, btnWidth, btnHeight,
        getText("IGUI_EFT_AdminPanel_ManagePlayers"), self, self.onClick)
    self.btnManagePlayers.internal = "MANAGE_PLAYERS"
    self.btnManagePlayers:initialise()
    self.btnManagePlayers:setEnable(false)
    self:addChild(self.btnManagePlayers)

    y = y - btnHeight - yPadding

    self.btnSetTime = ISButton:new(xPadding, y, btnWidth, btnHeight, "", self, self.onClick)
    self.btnSetTime.internal = "SET_TIME"
    self.btnSetTime:initialise()
    self.btnSetTime:setEnable(false)
    self:addChild(self.btnSetTime)


    -- Additional handling for the btnSetTime
    self.btnSetTimeTab = {
        prevInt = "",
        isChanging = false
    }

    --------------------
    -- INFO PANEL, TOP ONE

    self.panelInfo = ISRichTextPanel:new(0, 20, self:getWidth(), self:getHeight() - y)
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


    -- TOP of the panelInfo
    self:createIsRichTextPanel("labelInstancesAvailable", "panelInfo", 0, 0, labelWidth, labelHeight, labelHeight/4, AVAILABLE_INSTANCES_STR)
    self:createIsRichTextPanel("labelAssignedSafehouses", "panelInfo", labelWidth, 0, labelWidth, labelHeight, labelHeight/4, ASSIGNED_SAFEHOUSES_STR)

    -- Bottom of Panel Info
    self:createIsRichTextPanel("labelValInstancesAvailable", "panelInfo", 0, labelHeight + yPadding, labelWidth, labelHeight, 0, "")
    self:createIsRichTextPanel("labelValAssignedSafehouses", "panelInfo", labelWidth, labelHeight + yPadding, labelWidth, labelHeight, 0, "")

end


function BeforeMatchAdminPanel:onClick(btn)
    if btn.internal == 'START' then
        ClientState.isStartingMatch = true
        btn.internal = "STOP"
        btn:setTitle(MATCH_STOP_TEXT)
        -- Start timer. Show it on screen
        sendClientCommand(EFT_MODULES.Time, "StartMatchCountdown", { stopTime = PZ_EFT_CONFIG.MatchSettings.startMatchTime })
        TimePanel.Open("Starting match in...")
    elseif btn.internal == "STOP" then
        ClientState.isStartingMatch = false
        btn.internal = "START"
        btn:setTitle(MATCH_START_TEXT)
        sendClientCommand(EFT_MODULES.Time, "StopMatchCountdown", {})
        TimePanel.Close()
    elseif btn.internal == 'MANAGE_PLAYERS' then
        if self.openedPanel and self.openedPanel:getIsVisible() then
            self.openedPanel:close()
        else
            self.openedPanel = ManagePlayersPanel.Open(self:getRight(), self:getBottom() - self:getHeight())
        end
    elseif btn.internal == 'SET_TIME_DAY' then
        debugPrint("Setting Day Time")
        sendClientCommand(EFT_MODULES.Time, "SetDayTime", {})
        btn:setEnable(false)
        self.btnSetTimeTab.isChanging = true
        self.btnSetTimeTab.prevInt = 'SET_TIME_DAY'
    elseif btn.internal == 'SET_TIME_NIGHT' then
        debugPrint("Setting Night Time")
        sendClientCommand(EFT_MODULES.Time, "SetNightTime", {})
        btn:setEnable(false)
        self.btnSetTimeTab.isChanging = true
        self.btnSetTimeTab.prevInt = 'SET_TIME_NIGHT'
    end
end

function BeforeMatchAdminPanel:update()
    BaseAdminPanel.update(self)
    -- When starting the match, we'll disable the default close button
    self.closeButton:setEnable(not ClientState.isStartingMatch)
    self.btnManagePlayers:setEnable(not ClientState.isStartingMatch)


    -- Check hour 
    local time = getGameTime():getTimeOfDay()
    --debugPrint(time)
    if time > 9 and time < 21 then
        self.btnSetTime.internal = "SET_TIME_NIGHT"
        self.btnSetTime.title = getText("IGUI_EFT_AdminPanel_SetNightTime")

    else
        self.btnSetTime.internal = "SET_TIME_DAY"
        self.btnSetTime.title = getText("IGUI_EFT_AdminPanel_SetDayTime")
    end

    -- Reactivates the btnSetTime only when the internal has changed
    if self.btnSetTimeTab.isChanging then
        if self.btnSetTimeTab.prevInt ~= self.btnSetTime.internal then
            self.btnSetTime:setEnable(not ClientState.isStartingMatch)

            -- Reset the table
            self.btnSetTimeTab.prevInt = ""
            self.btnSetTimeTab.isChanging = false
        else
            self.btnSetTime:setEnable(false)
        end
    else
        self.btnSetTime:setEnable(not ClientState.isStartingMatch)
    end

    local valAssignedSafehousesText = " <CENTRE> -1"     -- TODO This is a placeholder!
    self.labelValAssignedSafehouses:setText(valAssignedSafehousesText)
    self.labelValAssignedSafehouses.textDirty = true
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
    return BaseAdminPanel.OnOpenPanel(BeforeMatchAdminPanel)
end

---Check if there's a panel already open, and closes it
---@return boolean
function BeforeMatchAdminPanel.OnClosePanel()
    return BaseAdminPanel.OnClosePanel(BeforeMatchAdminPanel)
end

return BeforeMatchAdminPanel
