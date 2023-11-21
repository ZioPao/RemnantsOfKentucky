local BaseAdminPanel = require("ROK/UI/BaseAdminPanel")
local ManagePlayersPanel = require("ROK/UI/BeforeMatch/ManagePlayersPanel")
--------------------------------

-- TODO Res scaling is broken


---@class BeforeMatchAdminPanel : BaseAdminPanel
local BeforeMatchAdminPanel = BaseAdminPanel:derive("BeforeMatchAdminPanel")
BeforeMatchAdminPanel.instance = nil


local MATCH_START_TEXT = getText("IGUI_AdminPanelBeforeMatch_StartMatch")
local MATCH_STOP_TEXT = getText("IGUI_AdminPanelBeforeMatch_Stop")
local AVAILABLE_INSTANCES_STR = getText("IGUI_AdminPanelBeforeMatch_InstancesAvailable")
local ASSIGNED_SAFEHOUSES_STR = getText("IGUI_AdminPanelBeforeMatch_SafehousesAssigned")



---@param x number
---@param y number
---@param width number
---@param height number
---@return BeforeMatchAdminPanel
function BeforeMatchAdminPanel:new(x, y, width, height)
    ---@type BeforeMatchAdminPanel
    local o = BaseAdminPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.isStartingMatch = false
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
    self.btnToggleMatch.internal = "START"      -- TODO Will swap when we click this
    self.btnToggleMatch:initialise()
    self:addChild(self.btnToggleMatch)

    y = y - btnHeight - yPadding*2      -- More padding from this
    self.btnMatchOptions = ISButton:new(xPadding, y, btnWidth, btnHeight,
        getText("IGUI_AdminPanelBeforeMatch_MatchOptions"), self, self.onClick)
    self.btnMatchOptions.internal = "MATCH_OPTIONS"
    self.btnMatchOptions:initialise()
    self.btnMatchOptions:setEnable(false)
    self:addChild(self.btnMatchOptions)

    y = y - btnHeight - yPadding
    self.btnManagePlayers = ISButton:new(xPadding, y, btnWidth, btnHeight,
        getText("IGUI_AdminPanelBeforeMatch_ManagePlayers"), self, self.onClick)
    self.btnManagePlayers.internal = "MANAGE_PLAYERS"
    self.btnManagePlayers:initialise()
    self.btnManagePlayers:setEnable(false)
    self:addChild(self.btnManagePlayers)

    y = y - btnHeight

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
    self.labelInstancesAvailable = ISRichTextPanel:new(0, 0, labelWidth, labelHeight)
    self.labelInstancesAvailable.autosetheight = false
    self.labelInstancesAvailable.marginBottom = 0
    self.labelInstancesAvailable.marginTop = labelHeight/4
    self.labelInstancesAvailable.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 }
    self.labelInstancesAvailable.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0 }
    self.labelInstancesAvailable:initialise()
    self.labelInstancesAvailable:setText(AVAILABLE_INSTANCES_STR)
    self.labelInstancesAvailable:paginate()
    self.panelInfo:addChild(self.labelInstancesAvailable)

    self.labelAssignedSafehouses = ISRichTextPanel:new(labelWidth, 0, labelWidth, labelHeight)
    self.labelAssignedSafehouses.autosetheight = false
    self.labelAssignedSafehouses.marginBottom = 0
    self.labelAssignedSafehouses.marginTop = labelHeight/4
    self.labelAssignedSafehouses.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 }
    self.labelAssignedSafehouses.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0 }
    self.labelAssignedSafehouses:initialise()
    self.labelAssignedSafehouses:setText(ASSIGNED_SAFEHOUSES_STR)
    self.labelAssignedSafehouses:paginate()
    self.panelInfo:addChild(self.labelAssignedSafehouses)

    ---------------------
    -- Bottom of Panel Info
    self.labelValInstancesAvailable = ISRichTextPanel:new(0, labelHeight, labelWidth, labelHeight)
    self.labelValInstancesAvailable.autosetheight = false
    self.labelValInstancesAvailable.marginBottom = 0
    self.labelValInstancesAvailable.marginTop = 0
    self.labelValInstancesAvailable.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 }
    self.labelValInstancesAvailable.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0 }
    self.labelValInstancesAvailable:initialise()
    self.labelValInstancesAvailable:paginate()
    self.panelInfo:addChild(self.labelValInstancesAvailable)

    self.labelValAssignedSafehouses = ISRichTextPanel:new(labelWidth, labelHeight, labelWidth, labelHeight)
    self.labelValAssignedSafehouses.autosetheight = false
    self.labelValAssignedSafehouses.marginBottom = 0
    self.labelValAssignedSafehouses.marginTop = 0
    self.labelValAssignedSafehouses.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 }
    self.labelValAssignedSafehouses.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0 }
    self.labelValAssignedSafehouses:initialise()
    self.labelValAssignedSafehouses:paginate()
    self.panelInfo:addChild(self.labelValAssignedSafehouses)
end


function BeforeMatchAdminPanel:onClick(btn)
    if btn.internal == 'START' then
        self.isStartingMatch = true
        btn.internal = "STOP"
        btn:setTitle(MATCH_STOP_TEXT)
        -- Start timer. Show it on screen
        sendClientCommand("PZEFT-Time", "StartMatchCountdown", { stopTime = PZ_EFT_CONFIG.MatchSettings.startMatchTime })
        TimePanel.Open("Starting match in...")
    elseif btn.internal == "STOP" then
        self.isStartingMatch = false
        btn.internal = "START"
        btn:setTitle(MATCH_START_TEXT)
        sendClientCommand("PZEFT-Time", "StopMatchCountdown", {})
        TimePanel.Close()
    elseif btn.internal == 'MATCH_OPTIONS' then
        -- TODO Implement match options
    elseif btn.internal == 'MANAGE_PLAYERS' then
        if self.openedPanel and self.openedPanel:getIsVisible() then
            self.openedPanel:close()
        else
            self.openedPanel = ManagePlayersPanel.Open(self:getRight(), self:getBottom() - self:getHeight())
        end
    end
end

function BeforeMatchAdminPanel:update()
    BaseAdminPanel.update(self)
    -- When starting the match, we'll disable the default close button
    self.closeButton:setEnable(not self.isStartingMatch)
    self.btnMatchOptions:setEnable(not self.isStartingMatch)
    self.btnManagePlayers:setEnable(not self.isStartingMatch)

    -- Handles Panel Info stuff
    -- TODO Set it bigger
    local valInstancesAvailableText = " <CENTRE> " .. tostring(math.floor(ClientState.availableInstances))
    self.labelValInstancesAvailable:setText(valInstancesAvailableText)
    self.labelValInstancesAvailable.textDirty = true

    local valAssignedSafehousesText = " <CENTRE> 4"     -- TODO PLaceholder!
    self.labelValAssignedSafehouses:setText(valAssignedSafehousesText)
    self.labelValAssignedSafehouses.textDirty = true
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
    -- TODO Request available safehouses

    return BaseAdminPanel.OnOpenPanel(BeforeMatchAdminPanel)
end

---Check if there's a panel already open, and closes it
---@return boolean
function BeforeMatchAdminPanel.OnClosePanel()
    return BaseAdminPanel.OnClosePanel(BeforeMatchAdminPanel)
end

return BeforeMatchAdminPanel
