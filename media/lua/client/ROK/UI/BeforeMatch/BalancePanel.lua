
-- TODO Finish this

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"
require "ISUI/ISButton"
---------------------------

---@class BalancePanel : ISPanel
local BalancePanel = ISPanel:derive("BalancePanel")

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
    self:addChild(self.balanceText)

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
    local md = PZEFT_UTILS.GetPlayerModData()
    local balance
    if md.bankAccount then
        balance = "$" .. tostring(md.bankAccount.balance)
    else
        balance = "..."
    end

    self.balanceText:setText(balance)
    self.balanceText.textDirty = true
end

function BalancePanel:setPosition(x, y)
    self:setX(x)
    self:setY(y)
end

------------------------------------------------- 


function BalancePanel.Open()
    if BalancePanel.instance then
        BalancePanel.instance:close()
    end

    local width = 300
    local height = 50
    local padding = 100
    local posX = getCore():getScreenWidth() - width - padding
    local posY = 0

    local panel = BalancePanel:new(posX, posY, width, height)
    panel:initialise()
    panel:addToUIManager()
    panel:bringToTop()

    return panel
end

function BalancePanel.Close()
    if BalancePanel.instance then
        BalancePanel.instance:close()
    end
end

function BalancePanel.HandleResolutionChange(oldW, oldH, w, h)
    if BalancePanel.instance and BalancePanel.instance:isVisible() then
        local width = 300
        local padding = 100
        local posX = w - width - padding
        local posY = 0
        BalancePanel.instance:setPosition(posX, posY)
    end
end

Events.OnResolutionChange.Add(BalancePanel.HandleResolutionChange)


return BalancePanel