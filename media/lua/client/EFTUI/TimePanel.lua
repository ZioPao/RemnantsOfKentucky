-- Used in conjuction with a BaseTimer\TimerHandler\CountdownHandler

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"
require "ISUI/ISButton"

-- TODO Make this local
TimePanel = ISPanel:derive("TimePanel")

function TimePanel:new(x, y, width, height, isStartingMatch)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.isStartingMatch = isStartingMatch
    o:initialise()

    TimePanel.instance = o
   return o
end

---Returns a string with the formatted time in minutes:seconds
---@param time number?
local function FormatTime(time)
    local minutes = math.floor((time%3600)/60)
    local seconds = math.floor(time%60)

    local addedColor = ""
    if minutes == 0 and seconds < 30 then
        local r = 1/(seconds/2)
        local g = 1 - r
        local b = 1 - r
        addedColor = string.format(" <RGB:%.2f,%.2f,%.2f> ", 1, g, b)
    else
        addedColor = string.format(" <RGB:%.2f,%.2f,%.2f> ", 1, 1, 1)
    end

    debugPrint(addedColor)

    local finalString = string.format(" %s <CENTRE> %02d:%02d", addedColor, minutes, seconds)

    -- TODO Check the current time, depending on this change color of the time on the panel.
    return finalString
end

function TimePanel:render()
    local timeNumber = tonumber(ClientState.currentTime)
    if timeNumber == nil or timeNumber <= 0 then
        self:close()
    end
	self.textPanel:setText(FormatTime(timeNumber))
	self.textPanel.textDirty = true
    if self.isStartingMatch then return end

    -- todo In game timer will fade out after some seconds
    -- TODO if we do it via update it could be faster depending on the framerate. Keep this in mind

    --self.color.a = self.timeText.color.a - 0.0001

end

function TimePanel:initialise()
	ISPanel.initialise(self)

    self.textPanel = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.textPanel:initialise()
    self:addChild(self.textPanel)

    self.textPanel.defaultFont = UIFont.Massive
    self.textPanel.anchorTop = false
    self.textPanel.anchorLeft = false
    self.textPanel.anchorBottom = false
    self.textPanel.anchorRight = false

    self.textPanel.marginLeft = 0
    self.textPanel.marginTop = self.height/4

    self.textPanel.marginRight = 0
    self.textPanel.marginBottom = 0
    self.textPanel.autosetheight = false
    self.textPanel.background = false

    self.textPanel:paginate()
end

-------------------------
-- Mostly debug stuff

function TimePanel.OnOpen()

    --debug_testCountdown()
    local width = 300
    local height = 100
    local padding = 50
    local posX = getCore():getScreenWidth() - width - padding
    local posY = getCore():getScreenHeight() - height - padding

    local panel = TimePanel:new(posX, posY, width, height, true)
    panel:initialise()
    panel:addToUIManager()
    panel:bringToTop()
    return panel
end

function TimePanel.Close()
    TimePanel.instance:close()
end