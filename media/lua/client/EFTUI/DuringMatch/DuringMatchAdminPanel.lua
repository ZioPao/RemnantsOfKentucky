-- TODO Make it local after tests
DuringMatchAdminPanel = ISCollapsableWindow:derive("DuringMatchAdminPanel")
DuringMatchAdminPanel.instance = nil

function DuringMatchAdminPanel:new(x, y, width, height)
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

    o.isMatchEnded = false

    DuringMatchAdminPanel.instance = o
    return o
end


-------------------------------------
function DuringMatchAdminPanel:getIsMatchEnded()
    return self.isMatchEnded
end

---Set isMatchEnded
---@param isMatchEnded boolean
function DuringMatchAdminPanel:setIsMatchEnded(isMatchEnded)
    self.isMatchEnded = isMatchEnded
end




---------------------------------------



function DuringMatchAdminPanel:createChildren()
    ISCollapsableWindow.createChildren(self)

    self.panelInfo = ISRichTextPanel:new(0, 20, self:getWidth(), self:getHeight() / 1.5)
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

    self.btnStop = ISButton:new(xPadding, self:getHeight() - btnHeight - yPadding, btnWidth, btnHeight,
        getText("IGUI_AdminPanelBeforeMatch_Stop"), self, self.onClick)
    self.btnStop.internal = "STOP"
    self.btnStop:initialise()
    self:addChild(self.btnStop)
end

function DuringMatchAdminPanel:onConfirmStop()
    -- TODO The teleporting stuff should be run on the server, not here
    print("Confirm! Teleporting back everyone")
    self:setIsMatchEnded(true)
    sendClientCommand("PZEFT-Time", "StartMatchEndCountdown", {stopTime = 10})

end

function DuringMatchAdminPanel:onClick(btn)
    if btn.internal == 'STOP' then
        local text = " <CENTRE> Are you sure you want to stop the match? Every player will be teleported back to their safehouse."

        -- TODO The teleporting stuff should be run on the server, not here
        self.confirmationPanel = ConfirmationPanel.Open(text, self:getX(), self:getY() + self:getHeight() + 20, self, self.onConfirmStop)
    end
end




function DuringMatchAdminPanel:update()
    ISCollapsableWindow.update(self)

    -- Updates match info
    local matchInfo = "Match time: 00:00 <LINE> Alive players: 10"

    if self:getIsMatchEnded() then
        matchInfo = matchInfo .. " <BR> <CENTRE> <RED> MATCH HAS ENDED!"
    end

    self.panelInfo:setText(matchInfo)
    self.panelInfo.textDirty = true

    if self.confirmationPanel and self.confirmationPanel.isOpen then
        self.btnStop:setEnable(false)
    else
        self.btnStop:setEnable(true)
    end

end

function DuringMatchAdminPanel:close()
    if self.confirmationPanel then
        self.confirmationPanel:close()
    end

    ISCollapsableWindow.close(self)
end

--*****************************************

function DuringMatchAdminPanel.OnOpenPanel()

    -- TODO This should be in a common class that gets inherited by this

    if DuringMatchAdminPanel.instance and DuringMatchAdminPanel.instance:getIsVisible() then
        DuringMatchAdminPanel.instance:close()
        ButtonManager["AdminPanelButton"]:setImage(BUTTONS_DATA_TEXTURES["AdminPanelButton"].OFF)
        return
    end

    
    -- TODO Make it scale based on resolution
    local width = 400
    local height = 300

    local x = getCore():getScreenWidth() / 2 - width
    local y = getCore():getScreenHeight() / 2 - height

    local pnl = DuringMatchAdminPanel:new(x, y, width, height)
    pnl:initialise()
    pnl:instantiate()
    pnl:addToUIManager()
    pnl:bringToTop()
    return pnl
end

---Check if there's a panel already open, and closes it
---@return boolean wasOpen 
function DuringMatchAdminPanel.OnClosePanel()
    local wasOpen = false
    if DuringMatchAdminPanel.instance then
        DuringMatchAdminPanel.instance:close()
        wasOpen = true
    end
    return wasOpen
end