local KillTrackerHandler = require("ROK/Match/KillTrackerHandler")
local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
local TilesScrollingListBox = require("ROK/UI/BaseComponents/TilesScrollingListBox")
----------------
---@class RecapScrollKilledPlayersPanel : ISPanelJoypad
local RecapScrollKilledPlayersPanel = ISPanelJoypad:derive("RecapScrollKilledPlayersPanel")

---@param x number
---@param y number
---@param width number
---@param height number
---@return RecapScrollKilledPlayersPanel
function RecapScrollKilledPlayersPanel:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    ---@cast o RecapScrollKilledPlayersPanel
    RecapScrollKilledPlayersPanel.instance = o
    return o
end

---This is run on the the ScrollingBoxList!
---@param x number
---@param y number
local function ScrollingListBoxOnMouseDown(self, x, y)
    if #self.items == 0 then return end
    local row = self:rowAt(x, y)

    if row > #self.items then
        row = #self.items
    end
    if row < 1 then
        row = 1
    end

    getSoundManager():playUISound("UISelectListItem")
    self.selected = row
    if self.onmousedown then
        self.onmousedown(self.target, self.items[self.selected].item)
    end

    self.parent:setSelectedItem(self.items[self.selected].item)
end



function RecapScrollKilledPlayersPanel:createChildren()
    self.panelYPadding = GenericUI.SMALL_FONT_HGT + 2 * 2
    self.panelHeight = self.height - self.panelYPadding - 10

    self.scrollingListBox = TilesScrollingListBox:new(0, 0, self.width, self.height, 3)
    self.scrollingListBox:initialise()
    self.scrollingListBox:instantiate()
    self.scrollingListBox:setAnchorRight(false) -- resize in update()
    self.scrollingListBox:setAnchorBottom(true)
    self.scrollingListBox.itemHeight = 2 + GenericUI.MEDIUM_FONT_HGT + 32 + 4
    self.scrollingListBox.selected = 0
    self.scrollingListBox.onMouseDown = ScrollingListBoxOnMouseDown
    self.scrollingListBox.joypadParent = self
    self.scrollingListBox.drawBorder = true
    self:addChild(self.scrollingListBox)

    self.scrollingListBox.SMALL_FONT_HGT = GenericUI.SMALL_FONT_HGT
    self.scrollingListBox.MEDIUM_FONT_HGT = GenericUI.MEDIUM_FONT_HGT

    self.scrollingListBox:setElementsPerRow(1)
    self.scrollingListBox.doDrawItem = RecapScrollKilledPlayersPanel.DrawItem
    self.scrollingListBox.onMouseDown = nil

    self:initialiseList(KillTrackerHandler.GetData())
end

function RecapScrollKilledPlayersPanel:initialiseList(victimsTable)
    if victimsTable == nil then return end
    local sortedVictims = {}
    for _, v in pairs(victimsTable) do
        table.insert(sortedVictims, v)
    end

    -- Sorting by timestamp
    ---@param a {timestamp : string}
    ---@param b {timestamp : string}
    ---@return boolean
    local function SortByTimestamp(a, b)
        return a.timestamp < b.timestamp
    end

    table.sort(sortedVictims, SortByTimestamp)


    for i = 1, #sortedVictims do
        local data = sortedVictims[i]
        self.scrollingListBox:addItem(data.victimUsername, data)
    end

    -- Select first item in the list automatically
    if #sortedVictims > 1 then
        self.scrollingListBox.selected = 1
    end
end

---@alias KilLTrack {victimUsername : string, timestamp : any}


---@param playersBox TilesScrollingListBox the parent
---@param y number
---@param item {item : KilLTrack, height : number}
---@param rowElementNumber number
---@return number
function RecapScrollKilledPlayersPanel.DrawItem(playersBox, y, item, rowElementNumber)
    if y + playersBox:getYScroll() >= playersBox.height then return y + item.height end
    if y + item.height + playersBox:getYScroll() <= 0 then return y + item.height end

    local a = 0.9

    local width = playersBox:getWidth() / playersBox.elementsPerRow
    local x = width * rowElementNumber

    local clipY = math.max(0, y + playersBox:getYScroll())
    local clipY2 = math.min(playersBox.height, y + playersBox:getYScroll() + playersBox.itemheight)

    -- Border of single item
    playersBox:drawRectBorder(x, y, width, item.height - 1, a, playersBox.borderColor.r, playersBox.borderColor.g,
        playersBox.borderColor.b)


    --* USER NAME *--
    local username = item.item.victimUsername
    local timestamp = item.item.timestamp
    playersBox:setStencilRect(x, clipY, width - 1, clipY2 - clipY)
    playersBox:drawText(username, x + 6, y + 2, 1, 1, 1, a, playersBox.font)

    --* TIMESTAMP *--
    -- FIX Timestamps are still completely fucked up
    --local timeStr = GenericUI.FormatTime(timestamp, false)
    -- https://www.lua.org/pil/22.1.html

    -- %X doesn't work in kahlua for some reason.
    --local timeStr = tostring(os.date('%H:%m', timestamp))
    local timeStr = GenericUI.FormatTime(tonumber(timestamp))
    local timeStrY = getTextManager():MeasureStringY(playersBox.font, timeStr)
    local timeStrX = getTextManager():MeasureStringX(playersBox.font, timeStr)

    local timeStrStartX = playersBox:getWidth() - timeStrX - 10

    playersBox:drawText(timeStr, timeStrStartX, y + 2 + 2, 1, 1, 1, a, playersBox.font)
    playersBox:clearStencilRect()

    return y + item.height
end

return RecapScrollKilledPlayersPanel
