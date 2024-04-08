local AdminTopPanel = require("ROK/UI/BaseComponents/AdminTopPanel")
local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
local ClientState = require("ROK/ClientState")

--------------------

---@class DuringTopPanel : AdminTopPanel
local DuringTopPanel = AdminTopPanel:derive("DuringTopPanel")

---@param x any
---@param y any
---@param width any
---@param height any
---@return DuringTopPanel
function DuringTopPanel:new(x, y, width, height)
    local o = AdminTopPanel:new(x, y, width, height, 25)
    setmetatable(o, self)
    self.__index = self

    Events.EveryOneMinute.Add(DuringTopPanel.RequestAlivePlayersUpdate)

    DuringTopPanel.instance = o

    return o
end

function DuringTopPanel.RequestAlivePlayersUpdate()

    ---@type DuringMatchAdminPanel
    local parent = DuringTopPanel.instance:getParent()

    debugPrint("Requesting players amount")

    if parent == nil or parent:getIsMatchEnded() == true then
        debugPrint("DuringTopPanel parent does not exist or match has ended, stopping request amount loop")
        Events.EveryOneMinute.Remove(DuringTopPanel.RequestAlivePlayersUpdate)
        return
    end

    --debugPrint("Asking for alive players")
    sendClientCommand(EFT_MODULES.Match, "SendAlivePlayersAmount", {})

end


function DuringTopPanel:createChildren()
    self:createRow("matchTime")
    self:createRow("alivePlayers")
end

function DuringTopPanel:prerender()

    ---@type ISLabel
    local timeLabelVal = self.matchTimeLabelVal
    timeLabelVal:setName(GenericUI.FormatTime(tonumber(ClientState.currentTime)))

    ---@type ISLabel
    local alivePlayersLabelVal = self.alivePlayersLabelVal
    alivePlayersLabelVal:setName("")
end

return DuringTopPanel





-- function TestDuringTopPanel()
--     local width = 350 * GenericUI.FONT_SCALE
--     local height = 50

--     local x = 100 --getCore():getScreenWidth() / 2 - width
--     local y = getCore():getScreenHeight() / 2 - height

--     local pnl = DuringTopPanel:new(x, y, width, height)
--     pnl:initialise()
--     pnl:instantiate()
--     pnl:addToUIManager()
--     pnl:bringToTop()
-- end