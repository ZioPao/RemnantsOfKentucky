---@class NotificationPanel : ISPanel
NotificationPanel = ISPanel:derive("NotificationPanel")

---Starts a new confirmation panel
---@param x number
---@param y number
---@param width number
---@param height number
---@param text string
---@return NotificationPanel
function NotificationPanel:new(x, y, width, height, text)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o:initialise()
    o.text = text
    NotificationPanel.instance = o

    ---@cast o NotificationPanel
    return o
end

function NotificationPanel:createChildren()
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
    self.textPanel:setText(self.text)
    self.textPanel:paginate()

    local yPadding = 10
    local xPadding = self:getWidth() / 3
    local btnWidth = 100
    local btnHeight = 25


    local yButton = self:getHeight() - yPadding - btnHeight

    self.btnOk = ISButton:new(xPadding, yButton, btnWidth, btnHeight, "OK", self, NotificationPanel.close)
    self.btnOk:initialise()
    self.btnOk.borderColor = { r = 1, g = 0, b = 0, a = 1 }
    self.btnOk:setEnable(true)
    self:addChild(self.btnOk)
end

-------------------------

---@return NotificationPanel
function NotificationPanel.Open(text)
    local width = 500
    local height = getTextManager():MeasureStringY(UIFont.Medium, text) + 200

    local x = (getCore():getScreenWidth() - width)/2
    local y = getCore():getScreenHeight()/2
    local panel = NotificationPanel:new(x, y, width, height, text)
    panel:initialise()
    panel:addToUIManager()
    panel:bringToTop()
    return panel
end




function NotificationPanel.Close()
    NotificationPanel.instance:close()
end

--return NotificationPanel