local BaseAdminPanel = require("ROK/UI/BaseComponents/BaseAdminPanel")
local ConfirmationPanel = require("ROK/UI/ConfirmationPanel")
local DuringTopPanel = require("ROK/UI/DuringMatch/DuringTopPanel")
local ClientState = require("ROK/ClientState")

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


function DuringMatchAdminPanel.SwitchPanel()
    if not isAdmin() then return end
    if DuringMatchAdminPanel.instance and DuringMatchAdminPanel.instance:isVisible() then
        DuringMatchAdminPanel.instance:close()
        DuringMatchAdminPanel.instance = nil
        local BeforeMatchAdminPanel = require("ROK/UI/BeforeMatch/BeforeMatchAdminPanel")
        BeforeMatchAdminPanel.OnOpenPanel()

    end
end

Events.PZEFT_MatchNotRunningAnymore.Add(DuringMatchAdminPanel.SwitchPanel)

return DuringMatchAdminPanel


