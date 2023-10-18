EFTGenericUI = {}


EFTGenericUI.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
EFTGenericUI.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()

---Returns a string with the formatted time in minutes:seconds
---@param time number?
EFTGenericUI.FormatTime = function(time)
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

    --debugPrint(addedColor)
    local finalString = string.format(" %s <CENTRE> %02d:%02d", addedColor, minutes, seconds)

    -- TODO Check the current time, depending on this change color of the time on the panel.
    return finalString
end