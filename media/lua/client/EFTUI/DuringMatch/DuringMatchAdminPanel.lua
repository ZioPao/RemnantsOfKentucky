local BaseAdminPanel = require("EFTUI/BaseAdminPanel")

DuringMatchAdminPanel = BaseAdminPanel:derive("DuringMatchAdminPanel")
DuringMatchAdminPanel.instance = nil

function DuringMatchAdminPanel:new(x, y, width, height)
    local o = BaseAdminPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

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
    BaseAdminPanel.createChildren(self)

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
    BaseAdminPanel.update(self)

    -- Updates match info
    local matchInfo

    if self:getIsMatchEnded() then
        matchInfo =" <CENTRE> <RED> THE MATCH HAS ENDED!"
        self.btnStop:setEnable(false)
    else
        -- Handle confirmation panel to stop the match
        self.btnStop:setEnable(self.confirmationPanel == nil or (self.confirmationPanel.isOpen ~= nil and self.confirmationPanel.isOpen == true))
        matchInfo = "Match time: " .. EFTGenericUI.FormatTime(tonumber(ClientState.currentTime)) .. " <LINE> Alive Players: 10"
    end

    self.panelInfo:setText(matchInfo)
    self.panelInfo.textDirty = true

end

function DuringMatchAdminPanel:close()
    if self.confirmationPanel then
        self.confirmationPanel:close()
    end

    BaseAdminPanel.close(self)
end

--*****************************************

function DuringMatchAdminPanel.OnOpenPanel()
    return BaseAdminPanel.OnOpenPanel(DuringMatchAdminPanel)
end

---Check if there's a panel already open, and closes it
---@return boolean 
function DuringMatchAdminPanel.OnClosePanel()
    return BaseAdminPanel.OnClosePanel(DuringMatchAdminPanel)
end