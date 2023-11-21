---@class GenericUI
---@field SMALL_FONT_HGT number
---@field MEDIUM_FONT_HGT number
local GenericUI = {}

GenericUI.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
GenericUI.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()

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

    --debugPrint(addedColor)
    local finalString = string.format(" %s <CENTRE> %02d:%02d", addedColor, minutes, seconds)

    -- TODO Check the current time, depending on this change color of the time on the panel.
    return finalString
end


function GenericUI.CreateISRichTextPanel(parent, name, x, y, width, height)
    parent[name] = ISRichTextPanel:new(x, y, width, height)
    parent[name]:initialise()
    parent:addChild(parent[name])
    parent[name].defaultFont = UIFont.Medium
    parent[name].anchorTop = true
    parent[name].anchorLeft = false
    parent[name].anchorBottom = true
    parent[name].anchorRight = false
    parent[name].marginLeft = 0
    parent[name].marginTop = 10
    parent[name].marginRight = 0
    parent[name].marginBottom = 0
    parent[name].autosetheight = false
    parent[name].background = false
    parent[name]:setText("")
    parent[name]:paginate()
end



return GenericUI