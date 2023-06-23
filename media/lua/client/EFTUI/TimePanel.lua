-- Used in conjuction with a BaseTimer\TimerHandler\CountdownHandler
-- TODO ISRichTextPanel that will show the time related stuff. Could be a timer or a countdown
-- TODO This shouldn't be constantly visible


require "ISUI/ISRichTextPanel"
require "ISUI/ISButton"

-- TODO I need to test if we can use ISRichTextPanel directly for this instead of a ISPanel
local TimePanel = ISRichTextPanel:derive("TimePanel")

function TimePanel:new(x, y, width, height, isStartingMatch)
	local o = ISRichTextPanel:new(x, y, width, height)

    setmetatable(o, self)
    self.__index = self

    o.isStartingMatch = isStartingMatch
    o:initialise()

   return o
end

---Returns a string with the formatted time in minutes:seconds
---@param time number?
local function FormatTime(time)
    local minutes = math.floor((time%3600)/60)
    local seconds = math.floor(time%60)

    -- TODO Check the current time, depending on this change color of the time on the panel.
    return string.format("%02d:%02d", minutes, seconds)
end

function TimePanel:render()
    local timeNumber = tonumber(ClientState.currentTime)
	self:setText(FormatTime(timeNumber))
	self.textDirty = true
    if self.isStartingMatch then return end

    -- todo In game timer will fade out after some seconds
    -- TODO if we do it via update it could be faster depending on the framerate. Keep this in mind

    self.color.a = self.timeText.color.a - 0.0001

end

function TimePanel:initialise()
	ISRichTextPanel.initialise(self)
end