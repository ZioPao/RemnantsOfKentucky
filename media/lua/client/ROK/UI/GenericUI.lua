---@class GenericUI
---@field SMALL_FONT_HGT number
---@field MEDIUM_FONT_HGT number
local GenericUI = {}

GenericUI.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
GenericUI.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()
GenericUI.LARGE_FONT_HGT = getTextManager():getFontHeight(UIFont.Large)

GenericUI.FONT_SCALE = GenericUI.MEDIUM_FONT_HGT / 14
GenericUI.HEADER_HGT = GenericUI.MEDIUM_FONT_HGT + 2 * 2
GenericUI.ENTRY_HGT = GenericUI.HEADER_HGT


---Returns a string with the formatted time in minutes:seconds
---@param time number?
function GenericUI.FormatTime(time)
    local minutes = math.floor((time % 3600) / 60)
    local seconds = math.floor(time % 60)

    local addedColor = ""
    if minutes == 0 and seconds < 30 then
        local r = 1 / (seconds / 2)
        local g = 1 - r
        local b = 1 - r
        addedColor = string.format(" <RGB:%.2f,%.2f,%.2f> ", 1, g, b)
    else
        addedColor = string.format(" <RGB:%.2f,%.2f,%.2f> ", 1, 1, 1)
    end

    -- Check the current time, depending on this change color of the time on the panel.
    local finalString = string.format(" %s <CENTRE> %02d:%02d", addedColor, minutes, seconds)
    return finalString
end

return GenericUI