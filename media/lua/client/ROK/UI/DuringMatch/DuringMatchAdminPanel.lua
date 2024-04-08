local BaseAdminPanel = require("ROK/UI/BaseComponents/BaseAdminPanel")
local ConfirmationPanel = require("ROK/UI/ConfirmationPanel")
local DuringTopPanel = require("ROK/UI/DuringMatch/DuringTopPanel")

-----------------

local STOP_MATCH_TEXT = getText("IGUI_EFT_AdminPanel_Stop")
local STOP_MATCH_ICON = getTexture("media/textures/BeforeMatchPanel/StopMatch.png")   -- https://www.freepik.com/icon/stop_13570077#fromView=family&page=1&position=2&uuid=6db48743-461d-4009-a1be-79aba60b71a3

--------------------------------

---@class DuringMatchAdminPanel : BaseAdminPanel
---@field availableInstancesAmount integer
---@field isMatchEnded boolean
local DuringMatchAdminPanel = BaseAdminPanel:derive("DuringMatchAdminPanel")
DuringMatchAdminPanel.instance = nil




---@param x number
---@param y number
---@param width number
---@param height number
---@return DuringMatchAdminPanel
function DuringMatchAdminPanel:new(x, y, width, height)
    local o = BaseAdminPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    ---@cast o DuringMatchAdminPanel
    DuringMatchAdminPanel.instance = o
    return o
end


function DuringMatchAdminPanel:getIsMatchEnded()
    return self.isMatchEnded
end

---Set isMatchEnded and disables the other labels
---@param isMatchEnded boolean
function DuringMatchAdminPanel:setIsMatchEnded(isMatchEnded)
    self.isMatchEnded = isMatchEnded
end

function DuringMatchAdminPanel:createChildren()
    BaseAdminPanel.createChildren(self)

    self.btnToggleMatch.btn.internal = "STOP"
    self.btnToggleMatch.btn:setTitle(STOP_MATCH_TEXT)
    self.btnToggleMatch:setTexture(STOP_MATCH_ICON)

    local th = self:titleBarHeight()
    self.topPanel = DuringTopPanel:new(0, th, self:getWidth(), self:getHeight()/4)
    self:addChild(self.topPanel)
end

function DuringMatchAdminPanel:onClick(btn)
    BaseAdminPanel.onClick(self, btn)

    -- BOTTOM PART
    if btn.internal == 'STOP' then
        local text =
        " <CENTRE> Are you sure you want to stop the match? Every player will be teleported back to their safehouse."
        self.confirmationPanel = ConfirmationPanel.Open(text, self:getX(), self:getY() + self:getHeight() + 20, self,
            self.onConfirmStop)
    end
end
function DuringMatchAdminPanel:onConfirmStop()
    self:setIsMatchEnded(true)
    sendClientCommand(EFT_MODULES.Match, "StartMatchEndCountdown", { stopTime = PZ_EFT_CONFIG.Client.Match.endMatchTime })
end

function DuringMatchAdminPanel:update()
    BaseAdminPanel.update(self)

    local isOptionsEnabled = (self.confirmationPanel and self.confirmationPanel:isVisible()) or self:getIsMatchEnded()
    self.btnToggleMatch:setEnable(not isOptionsEnabled)


    self.closeButton:setEnable(not isOptionsEnabled)
    self.btnMatchOptions:setEnable(not isOptionsEnabled)
    self.btnManagePlayersOption:setEnable(not isOptionsEnabled)
    self.btnManagementOption:setEnable(false)       -- Disabled for now
    self.btnEconomyManagement:setEnable(false)
end



--*****************************************--
---@return ISCollapsableWindow?
function DuringMatchAdminPanel.OnOpenPanel()
    sendClientCommand(EFT_MODULES.PvpInstances, "GetAmountAvailableInstances", {})
    sendClientCommand(EFT_MODULES.Match, "CheckIsAutomaticStart", {})

    return BaseAdminPanel.OnOpenPanel(DuringMatchAdminPanel)
end

---Check if there's a panel already open, and closes it
---@return boolean
function DuringMatchAdminPanel.OnClosePanel()
    return BaseAdminPanel.OnClosePanel(DuringMatchAdminPanel)
end

return DuringMatchAdminPanel




















-- local ClientState = require("ROK/ClientState")
-- local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
-- local BaseAdminPanel = require("ROK/UI/BaseComponents/BaseAdminPanel")

-- local MatchOptionsPanel = require("ROK/UI/BaseComponents/MatchOptionsPanel")
-- --------------------------------

-- ---@class DuringMatchAdminPanel : BaseAdminPanel
-- local DuringMatchAdminPanel = BaseAdminPanel:derive("DuringMatchAdminPanel")

-- function DuringMatchAdminPanel:new(x, y, width, height)
--     local o = BaseAdminPanel:new(x, y, width, height)
--     setmetatable(o, self)
--     self.__index = self

--     o.isMatchEnded = false
--     DuringMatchAdminPanel.instance = o

--     -- Event that handles updating the alive players thing
--     Events.EveryOneMinute.Add(DuringMatchAdminPanel.RequestAlivePlayersUpdate)


--     return o
-- end

-- function DuringMatchAdminPanel.RequestAlivePlayersUpdate()
--     if DuringMatchAdminPanel.instance == nil or DuringMatchAdminPanel.instance.isMatchEnded then
--         Events.EveryOneMinute.Remove(DuringMatchAdminPanel.RequestAlivePlayersUpdate)
--         return
--     end
--     --debugPrint("Asking for alive players")
--     sendClientCommand(EFT_MODULES.Match, "SendAlivePlayersAmount", {})

-- end
-- -------------------------------------
-- function DuringMatchAdminPanel:getIsMatchEnded()
--     return self.isMatchEnded
-- end

-- ---Set isMatchEnded and disables the other labels
-- ---@param isMatchEnded boolean
-- function DuringMatchAdminPanel:setIsMatchEnded(isMatchEnded)
--     self.isMatchEnded = isMatchEnded
-- end

-- ---------------------------------------

-- function DuringMatchAdminPanel:render()
--     BaseAdminPanel.render(self)
--     if self.openedPanel then
--         self.openedPanel:setX(self:getRight())
--         self.openedPanel:setY(self:getBottom() - self:getHeight())
--     end
-- end


-- function DuringMatchAdminPanel:createChildren()
--     BaseAdminPanel.createChildren(self)

--     local xPadding = GenericUI.X_PADDING
--     local yPadding = 20

--     local btnWidth = self:getWidth() - xPadding * 2
--     local btnHeight = 25

--     local y = self:getHeight() - btnHeight - yPadding

--     self.btnStop = ISButton:new(xPadding, y, btnWidth, btnHeight,
--         getText("IGUI_EFT_AdminPanel_Stop"), self, self.onClick)
--     self.btnStop.internal = "STOP"
--     self.btnStop:initialise()
--     self:addChild(self.btnStop)

--     y = y - btnHeight - yPadding * 1.5      -- More padding from this

--     self.btnMatchOptions = ISButton:new(xPadding, y, btnWidth, btnHeight, "", self, self.onClick)
--     self.btnMatchOptions.internal = "OPEN_MATCH_OPTIONS"
--     self.btnMatchOptions:initialise()
--     self.btnMatchOptions:setEnable(true)
--     self.btnMatchOptions:setTitle(getText("IGUI_EFT_AdminPanel_MatchOptions"))
--     self:addChild(self.btnMatchOptions)
--     -----------------------

--     self.panelInfo = ISPanel:new(0, 20, self:getWidth(), self:getHeight() - y)
--     self.panelInfo.background = true
--     self.panelInfo.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 }
--     self.panelInfo.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
--     self.panelInfo.marginTop = self.panelInfo:getHeight() / 2
--     self.panelInfo:initialise()
--     self:addChild(self.panelInfo)

--     self.labelTime = ISRichTextPanel:new(0, 30, self.panelInfo:getWidth(), 25)
--     self.labelTime:initialise()
--     self.labelTime:instantiate()
--     self.labelTime.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
--     self.labelTime:paginate()
--     self.panelInfo:addChild(self.labelTime)

--     self.labelAlivePlayers = ISRichTextPanel:new(0, 60, self.panelInfo:getWidth(), 25)
--     self.labelAlivePlayers:initialise()
--     self.labelAlivePlayers:instantiate()
--     self.labelAlivePlayers.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
--     self.labelAlivePlayers:paginate()
--     self.panelInfo:addChild(self.labelAlivePlayers)


-- end



-- function DuringMatchAdminPanel:onClick(btn)
--     if btn.internal == 'STOP' then
--         local text =
--         " <CENTRE> Are you sure you want to stop the match? Every player will be teleported back to their safehouse."

--         self.confirmationPanel = ConfirmationPanel.Open(text, self:getX(), self:getY() + self:getHeight() + 20, self,
--             self.onConfirmStop)
--     elseif btn.internal == "OPEN_MATCH_OPTIONS" then
--         GenericUI.ToggleSidePanel(self, MatchOptionsPanel)
--         return
--     end
-- end

-- function DuringMatchAdminPanel:update()
--     BaseAdminPanel.update(self)
--     local firstLabelText = "" -- Time or announcements
--     --debugPrint(ClientState.currentTime)
--     if self:getIsMatchEnded() or ClientState.currentTime <= 0 then
--         if self:getIsMatchEnded() then
--             firstLabelText = getText("IGUI_EFT_AdminPanel_MatchEnded")
--         end
--         self.btnStop:setEnable(false)
--         self:setAlivePlayersText(nil)
--     else
--         -- Handle confirmation panel to stop the match
--         local isStopDisabled = self.confirmationPanel and self.confirmationPanel:isVisible()
--         self.btnStop:setEnable(not isStopDisabled)

--         firstLabelText = getText("IGUI_EFT_AdminPanel_MatchTime", GenericUI.FormatTime(tonumber(ClientState.currentTime), true))
--     end

--     self.labelTime:setText(firstLabelText)
--     self.labelTime.textDirty = true

--     -- Close the panel automatically if the match is not running anymore
--     if not ClientState.GetIsMatchRunning() then
--         self:close()
--     end
-- end

-- function DuringMatchAdminPanel:setAlivePlayersText(text)
--     local fullText
--     if text == nil then
--         fullText = ""
--     else
--         fullText = "Alive Players: <CENTRE> " .. tostring(text)
--     end
--     local secondLabelText = fullText
--     self.labelAlivePlayers:setText(secondLabelText)
--     self.labelAlivePlayers.textDirty = true
-- end

-- function DuringMatchAdminPanel:close()
--     if self.confirmationPanel then
--         self.confirmationPanel:close()
--     end

--     if self.openedPanel then
--         self.openedPanel:close()
--     end

--     DuringMatchAdminPanel.instance = nil
--     BaseAdminPanel.close(self)
-- end

-- --*****************************************

-- function DuringMatchAdminPanel.OnOpenPanel()
--     return BaseAdminPanel.OnOpenPanel(DuringMatchAdminPanel)
-- end

-- ---Check if there's a panel already open, and closes it
-- ---@return boolean
-- function DuringMatchAdminPanel.OnClosePanel()
--     return BaseAdminPanel.OnClosePanel(DuringMatchAdminPanel)
-- end

-- return DuringMatchAdminPanel
