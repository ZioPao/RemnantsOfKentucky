-- TODO Make it local after tests
BeforeMatchAdminPanel = ISCollapsableWindow:derive("BeforeMatchAdminPanel")
BeforeMatchAdminPanel.instance = nil

function BeforeMatchAdminPanel:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.resizable = false

    o.width = width
    o.height = height

    o.variableColor = { r = 0.9, g = 0.55, b = 0.1, a = 1 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 1.0 }
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    o.moveWithMouse = true

    o.isStartingMatch = false

    BeforeMatchAdminPanel.instance = o
    return o
end

function BeforeMatchAdminPanel:createChildren()
    ISCollapsableWindow.createChildren(self)

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
        -- TODO Start timer. Show it on screen
        debug_testCountdown()
        TimePanel.Open()
    elseif btn.internal == 'MATCH_OPTIONS' then
    elseif btn.internal == 'MANAGE_PLAYERS' then
        self.openedPanel = ManagePlayersPanel.Open(self:getRight(), self:getBottom() - self:getHeight())
    elseif btn.internal == 'STOP' then
        self.isStartingMatch = false
        TimePanel.Close()
        -- TODO Stop countdown
    end
end

function BeforeMatchAdminPanel:update()
    ISCollapsableWindow.update(self)
    -- When starting the match, we'll disable the start button and enable the stop one
    self.btnStartMatch:setEnable(not self.isStartingMatch)
    self.btnMatchOptions:setEnable(not self.isStartingMatch)
    self.btnManagePlayers:setEnable(not self.isStartingMatch)


    self.btnStop:setVisible(self.isStartingMatch)
    self.btnStop:setEnable(self.isStartingMatch)



    -- Handles Panel Info stuff
    local instancesAvailableStr = getText("IGUI_AdminPanelBeforeMatch_InstancesAvailable", 100) ..
    "\n" .. getText("IGUI_AdminPanelBeforeMatch_SafehousesAssigned", 55)

    self.panelInfo:setText(instancesAvailableStr)
    self.panelInfo.textDirty = true


    -- TODO Maybe use a ontick since this isn't updated every tick and we'd want it to be fluid
    -- Updates right panel position
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

function BeforeMatchAdminPanel.OnOpenPanel()
    -- TODO Make it scale based on resolution
    local width = 400
    local height = 500

    local x = getCore():getScreenWidth() / 2 - width
    local y = getCore():getScreenHeight() / 2 - height

    local pnl = BeforeMatchAdminPanel:new(x, y, width, height)
    pnl:initialise()
    pnl:instantiate()
    pnl:addToUIManager()
    pnl:bringToTop()
    return pnl
end

