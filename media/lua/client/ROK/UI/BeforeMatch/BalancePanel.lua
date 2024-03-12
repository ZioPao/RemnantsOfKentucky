
-- TODO Finish this

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"
require "ISUI/ISButton"
---------------------------

---@class BalancePanel : ISPanel
---@field refBankAccount table      -- Reference of player mod data with the balance and all that stuff
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

    o.refBankAccount = nil


    ---@cast o BalancePanel
    BalancePanel.instance = o
    return o
end

function BalancePanel:createChildren()
    ISPanel.createChildren(self)

    self.background = true
    self.borderColor = {r=1,g=1,b=1,a=1}

    self.balanceText = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.balanceText:initialise()
    self:addChild(self.balanceText)

    self.balanceText.defaultFont = UIFont.Massive
    self.balanceText.anchorTop = true
    self.balanceText.anchorLeft = false
    self.balanceText.anchorBottom = true
    self.balanceText.anchorRight = false

    self.balanceText.marginLeft = 0
    self.balanceText.marginTop = 0
    self.balanceText.marginRight = 0
    self.balanceText.marginBottom = 0
    self.balanceText.autosetheight = false
    self.balanceText.background = false

    self.balanceText:paginate()

end

function BalancePanel:prerender()
    if self.background then
		self:drawRectStatic(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
		self:drawRectBorderStatic(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
	end


    local balance
    if self.refBankAccount.bankAccount then
        balance = "<CENTRE> <GREEN> $ <RGB:1,1,1> <SPACE> " .. tostring(self.refBankAccount.bankAccount.balance)
    else
        balance = "..."
    end

    self.balanceText:setText(balance)
    self.balanceText.textDirty = true
end


function BalancePanel:update()
    ISPanel.update(self)


    self.refBankAccount = PZEFT_UTILS.GetPlayerModData()
    if self.refBankAccount == nil then return end

    if self.refBankAccount.bankAccount then
        -- Calculate length
        local len = getTextManager():MeasureStringX(UIFont.Massive, tostring(self.refBankAccount.bankAccount.balance))
        debugPrint(len)
        if len > self:getWidth() then
            self:setWidth(len)
        end
    end
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

    local width = 250
    local height = 50
    local padding = 10 + width
    local posX = getCore():getScreenWidth() - width - padding
    local posY = 1

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