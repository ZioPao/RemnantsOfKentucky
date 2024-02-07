-- Used in conjuction with a BaseTimer\TimerHandler\CountdownHandler
require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"
require "ISUI/ISButton"
local ClientState = require("ROK/ClientState")
local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
---------------------------

---@class BalancePanel : ISPanel
BalancePanel = ISPanel:derive("BalancePanel")

---@param x number
---@param y number
---@param width number
---@param height number
---@return BalancePanel
function BalancePanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o:initialise()

    ---@cast o BalancePanel
    BalancePanel.instance = o
    return o
end

function BalancePanel:createChildren()
    ISPanel.createChildren(self)

    self.balanceText = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.balanceText:initialise()
    self:addChild(self.timePanel)

    self.balanceText.defaultFont = UIFont.Massive
    self.balanceText.anchorTop = false
    self.balanceText.anchorLeft = false
    self.balanceText.anchorBottom = false
    self.balanceText.anchorRight = false

    self.balanceText.marginLeft = 0
    self.balanceText.marginTop = self.height / 4

    self.balanceText.marginRight = 0
    self.balanceText.marginBottom = 0
    self.balanceText.autosetheight = false
    self.balanceText.background = false

    self.balanceText:paginate()

end

function BalancePanel:prerender()
    self.balanceText:setText("$100000000")
    self.balanceText.textDirty = true
end

------------------------------------------------- 

function BalancePanel.Open()
    if BalancePanel.instance then
        BalancePanel.instance:close()
    end

    debugPrint("Opening up timer")
    local width = 300
    local height = 100
    local padding = 50
    local posX = getCore():getScreenWidth() - width - padding
    local posY = height + padding

    local panel = BalancePanel:new(posX, posY, width, height)
    panel:initialise()
    panel:addToUIManager()
    panel:bringToTop()

    return panel
end


--return BalancePanel