
-- TODO Make it local after tests
BeforeMatchAdminPanel = ISCollapsableWindow:derive("BeforeMatchAdminPanel")
BeforeMatchAdminPanel.instance = nil

function BeforeMatchAdminPanel:new(x, y, width, height, coords)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
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


    AdminBeforeMatchMenu.instance = o
    return o
end

function BeforeMatchAdminPanel:createChildren()
    self.panelInfo = ISPanel:new(0, 10, self:getWidth(), self:getHeight()/4)
    self:addChild(self.panelInfo)

    self.labelInstancesAvailable = ISLabel:new(10, 10, 25, "", 1, 1, 1, 1, UIFont.Small, true)
    self.labelInstancesAvailable:initialise()
    self.labelInstancesAvailable:instantiate()
    self.panelInfo:addChild(self.labelInstancesAvailable)

    self.labelSafehousesAssigned = ISLabel:new(10, self.labelInstancesAvailable:getBottom() + 10, 25, "", 1, 1, 1, 1, UIFont.Small, true)
    self.labelSafehousesAssigned:initialise()
    self.labelSafehousesAssigned:instantiate()
    self.panelInfo:addChild(self.labelSafehousesAssigned)

    -----------------------

    local xPadding = 10
    local yOffset = self.panelInfo:getBottom() + 10

    local btnWidth = self:getWidth() - xPadding*2
    local btnHeight = 25

    self.btnStartMatch = ISButton:new(xPadding, yOffset, btnWidth, btnHeight, getText("IGUI_AdminPanelBeforeMatch_StartMatch"), self, self.onClick)
    self.btnStartMatch.internal = "START_MATCH"
    self.btnStartMatch:initialise()
    self.btnStartMatch:setEnable(false)
    self:addChild(self.btnStartMatch)

    yOffset = yOffset + self.btnStartMatch:getHeight() + 10

    self.btnMatchOptions = ISButton:new(xPadding, yOffset, btnWidth, btnHeight, getText("IGUI_AdminPanelBeforeMatch_MatchOptions"), self, self.onClick )
    self.btnMatchOptions.internal = "MATCH_OPTIONS"
    self.btnMatchOptions:initialise()
    self.btnMatchOptions:setEnable(false)
    self:addChild(self.btnMatchOptions)

    yOffset = yOffset + self.btnReload:getHeight() + 10

    self.btnManagePlayers = ISButton:new(xPadding, yOffset, btnWidth, btnHeight, getText("IGUI_AdminPanelBeforeMatch_ManagePlayers"), self, self.onClick )
    self.btnManagePlayers.internal = "MANAGE_PLAYERS"
    self.btnManagePlayers:initialise()
    self.btnManagePlayers:setEnable(false)
    self:addChild(self.btnManagePlayers)



    self.btnStop = ISButton:new(xPadding, self:getHeight() - btnHeight - 10, btnWidth, btnHeight, getText("IGUI_AdminPanelBeforeMatch_Stop"), self, self.onClick)
    self.btnStop.internal = "STOP"
    self.btnStop:initialise()
    self:addChild(self.btnStop)


end

function BeforeMatchAdminPanel:onClick(btn)
    if btn.internal == 'START_MATCH' then
        self.isStartingMatch = true
        -- TODO Start timer. Show it on screen 
    elseif btn.internal == 'MATCH_OPTIONS' then
    elseif btn.internal == 'MANAGE_PLAYERS' then

    elseif btn.internal == 'STOP' then
        self.isStartingMatch = false
    end

end

function BeforeMatchAdminPanel:update()

    -- When starting the match, we'll disable the start button and enable the stop one
    self.btnStartMatch:setEnable(not self.isStartingMatch)
    self.btnStop:setVisible(self.isStartingMatch)
    self.btnStop:setEnable(self.isStartingMatch)


end

function BeforeMatchAdminPanel:setVisible(visible)
    self.javaObject:setVisible(visible)
end

function BeforeMatchAdminPanel.OnOpenPanel(coords)
    local pnl = BeforeMatchAdminPanel:new(50, 200, 200, 400)
    pnl:initialise()
    pnl:addToUIManager()
    pnl:bringToTop()
    return pnl
end

