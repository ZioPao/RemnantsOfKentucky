---@class BlackScreen : ISPanelJoypad
---@field text string
---@field textX number
---@field textY number
local BlackScreen = ISPanelJoypad:derive("BlackScreen")


function BlackScreen:new()
    local o = ISPanelJoypad:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 1 }

    BlackScreen.instance = o
    return o
end

function BlackScreen:initialise()
    ISPanelJoypad.initialise(self)

    self.text = getText("UI_EFT_Wait")
    self.textX = (self.width - getTextManager():MeasureStringX(UIFont.Massive, self.text))/2
    self.textY = self.height/2

end

function BlackScreen:prerender()
    self:drawRect(0, 0, self:getWidth(), self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    self:drawText(self.text, self.textX, self.textY, 1, 1, 1, 1, UIFont.Massive)
end

-- function BlackScreen:render()
--     ISPanelJoypad.render(self)
-- end

-------------------

function BlackScreen.Open()
    if not isClient() then return end       -- SP workaround
    --debugPrint("Opening black screen")
    local blackScreen = BlackScreen:new()
    blackScreen:initialise()
    blackScreen:addToUIManager()
end

function BlackScreen.Close()
    --debugPrint("Closing black screen")
    if BlackScreen.instance then
        BlackScreen.instance:close()
    end
end

return BlackScreen