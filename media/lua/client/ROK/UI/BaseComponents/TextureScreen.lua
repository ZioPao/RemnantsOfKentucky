---@class TextureScreen : ISPanel
---@field text string
---@field textX number
---@field textY number
---@field isClosing boolean
---@field closingTime number
local TextureScreen = ISPanel:derive("TextureScreen")

---@return TextureScreen
function TextureScreen:new()
    local o = ISPanel:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
    setmetatable(o, self)
    self.__index = self

    o.backgroundTexture = nil
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 1 }
    o.isClosing = false
    o.closingTime = 0

    o.fade = UITransition.new()
    o.fade:setIgnoreUpdateTime(true)

    o.cAlpha = 1            -- current alpha

    ---@cast o TextureScreen
    return o
end

function TextureScreen:initialise()
    ISPanel.initialise(self)

    self.fade:init(2000, false)
    self.fade:update()

    self.text = getText("UI_EFT_Wait")
    self.textX = (self.width - getTextManager():MeasureStringX(UIFont.Massive, self.text))/2
    self.textY = self.height/2

end

function TextureScreen:prerender()
    if self.cAlpha <= 0 then
        self:close()
    end

    if self.isClosing then
        self.fade:update()
        self.cAlpha = self.cAlpha - self.fade:fraction()
    end

    if self.backgroundTexture then
        self:drawTextureScaled(self.backgroundTexture, 0, 0, self.width, self.height, self.cAlpha, 1, 1, 1)
    else
        self:drawRect(0, 0, self:getWidth(), self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    end
end

function TextureScreen:startFade()
    debugPrint("Start fading panel")

    if self.isClosing == false then
        self.isClosing = true
        self.closingTime = 0
    end
end

function TextureScreen:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

return TextureScreen