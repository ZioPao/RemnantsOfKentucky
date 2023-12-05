local backgroundTexture = getTexture("media/textures/ROK_LoadingScreen.png")


---@class BlackScreen : ISPanel
---@field text string
---@field textX number
---@field textY number
---@field isClosing boolean
---@field closingTime number
local BlackScreen = ISPanel:derive("BlackScreen")

---@return BlackScreen
function BlackScreen:new()
    local o = ISPanel:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 1 }
    o.isClosing = false
    o.closingTime = 0

    ---@cast o BlackScreen

    BlackScreen.instance = o
    return o
end

function BlackScreen:initialise()
    ISPanel.initialise(self)

    self.text = getText("UI_EFT_Wait")
    self.textX = (self.width - getTextManager():MeasureStringX(UIFont.Massive, self.text))/2
    self.textY = self.height/2

end

function BlackScreen:prerender()

    local alpha = 1
    if self.isClosing then
        self.closingTime = self.closingTime + ((1.0 / 60)*getGameTime():getMultiplier())
    end
    alpha = 1 - self.closingTime

    self:drawTextureScaled(backgroundTexture, 0, 0, self.width, self.height, alpha, 1, 1, 1)
    self:drawText(self.text, self.textX, self.textY, 1, 1, 1, alpha, UIFont.Massive)

    if alpha <= 0 then
        self:close()
    end
end

function BlackScreen:startFade()
    if self.isClosing == false then
        self.isClosing = true
        self.closingTime = 0
    end
end

function BlackScreen:close()
    self:setVisible(false)
    self:removeFromUIManager()
    BlackScreen.instance = nil
end

-------------------

function BlackScreen.Open()
    if not isClient() then return end       -- SP workaround
    if getPlayer():isDead() then return end -- Workaround to prevent issues when player is dead
    if BlackScreen.instance ~= nil then return end
    debugPrint("Opening black screen")
    local blackScreen = BlackScreen:new()
    blackScreen:initialise()
    blackScreen:addToUIManager()
end

function BlackScreen.Close()
    --debugPrint("Closing black screen")
    if BlackScreen.instance then
        debugPrint("black screen instance available, closing")
        BlackScreen.instance:startFade()
    end
end

function BlackScreen.HandleResolutionChange(oldW, oldH, w, h)
    if BlackScreen.instance then
        BlackScreen.instance:setWidth(w)
        BlackScreen.instance:setHeight(h)
    end
end

Events.OnResolutionChange.Add(BlackScreen.HandleResolutionChange)

return BlackScreen