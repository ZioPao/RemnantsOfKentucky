local backgroundTexture = getTexture("media/textures/ROK_LoadingScreen.png")


---@class LoadingScreen : ISPanel
---@field text string
---@field textX number
---@field textY number
---@field isClosing boolean
---@field closingTime number
local LoadingScreen = ISPanel:derive("LoadingScreen")

---@return LoadingScreen
function LoadingScreen:new()
    local o = ISPanel:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 1 }
    o.isClosing = false
    o.closingTime = 0

    ---@cast o LoadingScreen

    LoadingScreen.instance = o
    return o
end

function LoadingScreen:initialise()
    ISPanel.initialise(self)

    self.text = getText("UI_EFT_Wait")
    self.textX = (self.width - getTextManager():MeasureStringX(UIFont.Massive, self.text))/2
    self.textY = self.height/2

end

function LoadingScreen:prerender()

    local alpha = 1
    if self.isClosing then
        self.closingTime = self.closingTime + ((2.0 / 60)*getGameTime():getMultiplier())
    end
    alpha = 1 - self.closingTime

    self:drawTextureScaled(backgroundTexture, 0, 0, self.width, self.height, alpha, 1, 1, 1)
    self:drawText(self.text, self.textX, self.textY, 1, 1, 1, alpha, UIFont.Massive)

    if alpha <= 0 then
        self:close()
    end
end

function LoadingScreen:startFade()
    if self.isClosing == false then
        self.isClosing = true
        self.closingTime = 0
    end
end

function LoadingScreen:close()
    self:setVisible(false)
    self:removeFromUIManager()
    LoadingScreen.instance = nil
end

-------------------

function LoadingScreen.Open()
    if not isClient() then return end       -- SP workaround
    if getPlayer():isDead() then return end -- Workaround to prevent issues when player is dead
    if LoadingScreen.instance ~= nil then return end
    debugPrint("Opening black screen")
    local LoadingScreen = LoadingScreen:new()
    LoadingScreen:initialise()
    LoadingScreen:addToUIManager()
end

function LoadingScreen.Close()
    --debugPrint("Closing black screen")
    if LoadingScreen.instance then
        debugPrint("black screen instance available, closing")
        LoadingScreen.instance:startFade()
    end
end

function LoadingScreen.HandleResolutionChange(oldW, oldH, w, h)
    if LoadingScreen.instance then
        LoadingScreen.instance:setWidth(w)
        LoadingScreen.instance:setHeight(h)
    end
end

Events.OnResolutionChange.Add(LoadingScreen.HandleResolutionChange)

return LoadingScreen