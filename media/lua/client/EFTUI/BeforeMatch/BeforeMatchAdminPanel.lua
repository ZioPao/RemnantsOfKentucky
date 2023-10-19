local BaseAdminPanel = require("EFTUI/BaseAdminPanel")
local ManagePlayersPanel = require("EFTUI/BeforeMatch/ManagePlayersPanel")
local BeforeMatchAdminPanel = BaseAdminPanel:derive("BeforeMatchAdminPanel")
BeforeMatchAdminPanel.instance = nil

---
---@param x any
---@param y any
---@param width any
---@param height any
---@return ISCollapsableWindow
function BeforeMatchAdminPanel:new(x, y, width, height)
    local o = BaseAdminPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.isStartingMatch = false
    BeforeMatchAdminPanel.instance = o
    return o
end

function BeforeMatchAdminPanel:createChildren()
    BaseAdminPanel.createChildren(self)

    self.panelInfo = ISRichTextPanel:new(0, 20, self:getWidth(), self:getHeight() / 4)
    self.panelInfo.autosetheight = false
    self.panelInfo.background = true
    self.panelInfo.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 }
    self.panelInfo.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.panelInfo.marginTop = self.panelInfo:getHeight() / 2
    self.panelInfo:initialise()
    self.panelInfo:paginate()
    self:addChild(self.panelInfo)

    -- TODO Maybe a bit of separation between the infos would be nice.

    -- self.labelInstancesAvailable = ISRichTextPanel:new(0, 0, self.panelInfo:getWidth(), 25)
    -- self.labelInstancesAvailable:initialise()
    -- self.labelInstancesAvailable:instantiate()
    -- self.panelInfo:addChild(self.labelInstancesAvailable)

    -- self.labelSafehousesAssigned = ISLabel:new(10, self.labelInstancesAvailable:getBottom() + 10, 25, "", 1, 1, 1, 1, UIFont.Small, true)
    -- self.labelSafehousesAssigned:initialise()
    -- self.labelSafehousesAssigned:instantiate()
    -- self.panelInfo:addChild(self.labelSafehousesAssigned)

    -----------------------

    local xPadding = 20
    local yPadding = 20
    local yOffset = self.panelInfo:getBottom() + yPadding

    local btnWidth = self:getWidth() - xPadding * 2
    local btnHeight = 25

    self.btnStartMatch = ISButton:new(xPadding, yOffset, btnWidth, btnHeight,
        getText("IGUI_AdminPanelBeforeMatch_StartMatch"), self, self.onClick)
    self.btnStartMatch.internal = "START_MATCH"
    self.btnStartMatch:initialise()
    self.btnStartMatch:setEnable(false)
    self:addChild(self.btnStartMatch)

    yOffset = yOffset + self.btnStartMatch:getHeight() + yPadding

    self.btnMatchOptions = ISButton:new(xPadding, yOffset, btnWidth, btnHeight,
        getText("IGUI_AdminPanelBeforeMatch_MatchOptions"), self, self.onClick)
    self.btnMatchOptions.internal = "MATCH_OPTIONS"
    self.btnMatchOptions:initialise()
    self.btnMatchOptions:setEnable(false)
    self:addChild(self.btnMatchOptions)

    yOffset = yOffset + self.btnMatchOptions:getHeight() + yPadding

    self.btnManagePlayers = ISButton:new(xPadding, yOffset, btnWidth, btnHeight,
        getText("IGUI_AdminPanelBeforeMatch_ManagePlayers"), self, self.onClick)
    self.btnManagePlayers.internal = "MANAGE_PLAYERS"
    self.btnManagePlayers:initialise()
    self.btnManagePlayers:setEnable(false)
    self:addChild(self.btnManagePlayers)


    self.btnStop = ISButton:new(xPadding, self:getHeight() - btnHeight - 10, btnWidth, btnHeight,
        getText("IGUI_AdminPanelBeforeMatch_Stop"), self, self.onClick)
    self.btnStop.internal = "STOP"
    self.btnStop:initialise()
    self:addChild(self.btnStop)
end

function BeforeMatchAdminPanel:onClick(btn)
    if btn.internal == 'START_MATCH' then
        self.isStartingMatch = true
        -- Start timer. Show it on screen
        sendClientCommand("PZEFT-Time", "StartMatchCountdown", {stopTime = PZ_EFT_CONFIG.MatchSettings.startMatchTime})
        TimePanel.Open("Starting match in...")
    elseif btn.internal == 'MATCH_OPTIONS' then
        -- TODO Implement match options
    elseif btn.internal == 'MANAGE_PLAYERS' then
        if self.openedPanel and self.openedPanel:getIsVisible() then
            self.openedPanel:close()
        else
            self.openedPanel = ManagePlayersPanel.Open(self:getRight(), self:getBottom() - self:getHeight())
        end
    elseif btn.internal == 'STOP' then
        self.isStartingMatch = false
        sendClientCommand("PZEFT-Time", "StopMatchCountdown", {})
        TimePanel.Close()
    end
end

function BeforeMatchAdminPanel:update()
    BaseAdminPanel.update(self)
    -- When starting the match, we'll disable the start button and default close button and enable the stop one
    self.closeButton:setEnable(not self.isStartingMatch)

    self.btnStartMatch:setEnable(not self.isStartingMatch)
    self.btnMatchOptions:setEnable(not self.isStartingMatch)
    self.btnManagePlayers:setEnable(not self.isStartingMatch)


    self.btnStop:setVisible(self.isStartingMatch)
    self.btnStop:setEnable(self.isStartingMatch)

    -- Handles Panel Info stuff

    -- TODO Updating it in real time could be costly

    -- 100 instances by default
    -- 99 safehouses by default


    local instancesAvailableStr = getText("IGUI_AdminPanelBeforeMatch_InstancesAvailable", ClientState.availableInstances) ..
    "\n" .. getText("IGUI_AdminPanelBeforeMatch_SafehousesAssigned", -1)

    self.panelInfo:setText(instancesAvailableStr)
    self.panelInfo.textDirty = true
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
    -- TODO Request available instances
    -- TODO Request available safehouses


    return BaseAdminPanel.OnOpenPanel(BeforeMatchAdminPanel)
end

---Check if there's a panel already open, and closes it
---@return boolean
function BeforeMatchAdminPanel.OnClosePanel()
    return BaseAdminPanel.OnClosePanel(BeforeMatchAdminPanel)
end


return BeforeMatchAdminPanel