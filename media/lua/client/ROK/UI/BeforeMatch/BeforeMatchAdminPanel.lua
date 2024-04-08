local BaseAdminPanel = require("ROK/UI/BaseComponents/BaseAdminPanel")
local TimePanel = require("ROK/UI/TimePanel")
local ClientState = require("ROK/ClientState")


local BeforeTopPanel = require("ROK/UI/BeforeMatch/BeforeTopPanel")


--------------------------------
local START_MATCH_TEXT = getText("IGUI_EFT_AdminPanel_StartMatch")
local STOP_MATCH_TEXT = getText("IGUI_EFT_AdminPanel_Stop")
local AVAILABLE_INSTANCES_STR = getText("IGUI_EFT_AdminPanel_InstancesAvailable")


local START_MATCH_ICON = getTexture("media/textures/BeforeMatchPanel/StartMatch.png") -- https://www.freepik.com/icon/play_14441317#fromView=family&page=1&position=0&uuid=6c560048-e143-4f62-bae1-92319409fae7
local STOP_MATCH_ICON = getTexture("media/textures/BeforeMatchPanel/StopMatch.png")   -- https://www.freepik.com/icon/stop_13570077#fromView=family&page=1&position=2&uuid=6db48743-461d-4009-a1be-79aba60b71a3

--------------------------------

---@class BeforeMatchAdminPanel : BaseAdminPanel
local BeforeMatchAdminPanel = BaseAdminPanel:derive("BeforeMatchAdminPanel")
BeforeMatchAdminPanel.instance = nil




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

    local th = self:titleBarHeight()
    self.topPanel = BeforeTopPanel:new(0, th, self:getWidth(), self:getHeight()/4)
    self:addChild(self.topPanel)
end

function BeforeMatchAdminPanel:onClick(btn)
    BaseAdminPanel.onClick(self, btn)

    -- BOTTOM PART
    if btn.internal == 'START' then
        ClientState.SetIsStartingMatch(true)
        btn.internal = "STOP"
        btn.parent:setTexture(STOP_MATCH_ICON)
        btn:setTitle(STOP_MATCH_TEXT) -- Start timer. Show it on screen
        sendClientCommand(EFT_MODULES.Match, "StartCountdown", { stopTime = PZ_EFT_CONFIG.Client.Match.startMatchTime })
        --TimePanel.Open("")
    elseif btn.internal == "STOP" then
        ClientState.SetIsStartingMatch(false)
        btn.internal = "START"
        btn.parent:setTexture(START_MATCH_ICON)
        btn:setTitle(START_MATCH_TEXT)
        sendClientCommand(EFT_MODULES.Match, "StopCountdown", {})
        TimePanel.Close()
    end
end

function BeforeMatchAdminPanel:update()
    BaseAdminPanel.update(self)

    -- Buttons

    self.btnToggleMatch:setEnable(ClientState.GetAvailableInstances() > 0 and not ClientState.GetIsAutomaticStart())

    -- When starting the match, we'll disable various buttons
    local isStartingMatch = ClientState.GetIsStartingMatch()

    self.closeButton:setEnable(not isStartingMatch)
    self.btnMatchOptions:setEnable(not isStartingMatch)
    self.btnManagePlayersOption:setEnable(not isStartingMatch)
    self.btnManagementOption:setEnable(not isStartingMatch)
    self.btnEconomyManagement:setEnable(not isStartingMatch)
end


function BeforeMatchAdminPanel:close()
    if self.openedPanel then
        self.openedPanel:close()
    end

    ISCollapsableWindow.close(self)
end

-- TODO Merge admin panels in one with switching modules instead


--* Before Match
---@param amount integer
function BeforeMatchAdminPanel:setAvailableInstancesAmount(amount)
    self.availableInstancesAmount = amount
end

function BeforeMatchAdminPanel:setAvailableInstancesText(text)
    local valInstancesAvailableText = " <CENTRE> " .. tostring(text)
    self.labelValInstancesAvailable:setText(valInstancesAvailableText)
    self.labelValInstancesAvailable.textDirty = true
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
