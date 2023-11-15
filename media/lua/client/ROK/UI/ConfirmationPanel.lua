local ConfirmationPanel = ISPanel:derive("ConfirmationPanel")

---Starts a new confirmation panel
---@param x number
---@param y number
---@param width number
---@param height number
---@param alertText string
---@param onConfirmFunc function
---@return ISPanel
function ConfirmationPanel:new(x, y, width, height, alertText, parentPanel, onConfirmFunc)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o:initialise()
    o.alertText = alertText
    o.onConfirmFunc = onConfirmFunc
    o.parentPanel = parentPanel
    ConfirmationPanel.instance = o
    return o
end

function ConfirmationPanel:createChildren()
    ISPanel.createChildren(self)
    self.borderColor = { r = 1, g = 0, b = 0, a = 1 }

    self.textPanel = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.textPanel:initialise()
    self:addChild(self.textPanel)
    self.textPanel.defaultFont = UIFont.Medium
    self.textPanel.anchorTop = true
    self.textPanel.anchorLeft = false
    self.textPanel.anchorBottom = true
    self.textPanel.anchorRight = false
    self.textPanel.marginLeft = 0
    self.textPanel.marginTop = 10
    self.textPanel.marginRight = 0
    self.textPanel.marginBottom = 0
    self.textPanel.autosetheight = false
    self.textPanel.background = false
    self.textPanel:setText(self.alertText)
    self.textPanel:paginate()

    local yPadding = 10
    local xPadding = self:getWidth() / 4
    local btnWidth = 100
    local btnHeight = 25


    local yButton = self:getHeight() - yPadding - btnHeight

    self.btnYes = ISButton:new(xPadding, yButton, btnWidth, btnHeight, "Yes", self, self.onClick)
    self.btnYes.internal = "YES"
    self.btnYes:initialise()
    self.btnYes.borderColor = { r = 1, g = 0, b = 0, a = 1 }
    self.btnYes:setEnable(true)
    self:addChild(self.btnYes)

    self.btnNo = ISButton:new(self:getWidth() - xPadding - btnWidth, yButton, btnWidth, btnHeight, "No", self,
        self.onClick)
    self.btnNo.internal = "NO"
    self.btnNo:initialise()
    self.btnNo:setEnable(true)
    self:addChild(self.btnNo)
end

function ConfirmationPanel:onClick(btn)
    if btn.internal == 'YES' then
        print("YES")
        self.onConfirmFunc(self.parentPanel)
        self:close()
    elseif btn.internal == 'NO' then
        print("NO")
        self:close()
    end
end

-- function ConfirmationPanel:close()
--     print("Closing confirmation panel")
--     ISPanel.close(self)
-- end

-------------------------
-- Mostly debug stuff

function ConfirmationPanel.Open(alertText, x, y, parentPanel, onConfirmFunc)
    local width = 500
    local height = 120

    local panel = ConfirmationPanel:new(x, y, width, height, alertText, parentPanel, onConfirmFunc)
    panel:initialise()
    panel:addToUIManager()
    panel:bringToTop()
    return panel
end

function ConfirmationPanel.Close()
    ConfirmationPanel.instance:close()
end

return ConfirmationPanel