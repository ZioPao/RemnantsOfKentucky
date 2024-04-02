---@class GenericUI
---@field SMALL_FONT_HGT number
---@field MEDIUM_FONT_HGT number
local GenericUI = {}

GenericUI.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
GenericUI.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()
GenericUI.LARGE_FONT_HGT = getTextManager():getFontHeight(UIFont.Large)

GenericUI.FONT_SCALE = GenericUI.SMALL_FONT_HGT / 16

if GenericUI.FONT_SCALE < 1 then GenericUI.FONT_SCALE = 1 end

GenericUI.HEADER_HGT = GenericUI.MEDIUM_FONT_HGT + 2 * 2
GenericUI.ENTRY_HGT = GenericUI.HEADER_HGT


-- Padding is gonna be the same for every interface
GenericUI.X_PADDING = 10

---Returns a string with the formatted time in minutes:seconds
---@param time number?
---@param useRichText boolean?
function GenericUI.FormatTime(time, useRichText)
    local minutes = math.floor((time % 3600) / 60)
    local seconds = math.floor(time % 60)

    local finalString
    if useRichText then
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
        finalString = string.format(" %s <CENTRE> %02d:%02d", addedColor, minutes, seconds)
    else
        finalString = string.format("%02d:%02d", minutes, seconds)
    end

    return finalString
end

function GenericUI.ToggleSidePanel(parent, NewPanel)

    -- Check if side panel is already open
    if parent.openedPanel then
        if parent.openedPanel:getIsVisible() then
            parent.openedPanel:close()
            if parent.openedPanel.Type == NewPanel.Type then
                return
            end
        end
    end

    local width = parent:getWidth()   -- SHITTY Fix this
    local height = parent:getHeight()
    parent.openedPanel = NewPanel.Open(parent:getRight(), parent:getBottom() - parent:getHeight(), width, height)

end

return GenericUI