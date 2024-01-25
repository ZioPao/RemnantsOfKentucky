-- TODO Wrong base class, we don't want Items
local GenericUI = require("ROK/UI/BaseComponents/GenericUI")

local TilesScrollingListBox = require("ROK/UI/BaseComponents/TilesScrollingListBox")
----------------
---@class RecapScrollKilledPlayersPanel : ISPanelJoypad
local RecapScrollKilledPlayersPanel = ISPanelJoypad:derive("RecapScrollKilledPlayersPanel")

function RecapScrollKilledPlayersPanel:new(x, y, width, height)
    ---@type RecapScrollKilledPlayersPanel
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
    local function SortByTimestamp(a,b)
        return a.timestamp < b.timestamp
    end

    table.sort(sortedVictims, SortByTimestamp)


    for i=1, #sortedVictims do
        local data = sortedVictims[i]
        self.scrollingListBox:addItem(data.victimUsername, data)
    end

    -- Select first item in the list automatically
    if #sortedVictims > 1 then
        self.scrollingListBox.selected = 1
    end
end


---@alias KilLTrack {victimUsername : string, timestamp : any}


---@param itemsBox TilesScrollingListBox the parent
---@param y number
---@param item {item : KilLTrack, height : number}
---@param rowElementNumber number
---@return number
function RecapScrollKilledPlayersPanel.DrawItem(itemsBox, y, item, rowElementNumber)
    if y + itemsBox:getYScroll() >= itemsBox.height then return y + item.height end
    if y + item.height + itemsBox:getYScroll() <= 0 then return y + item.height end

    local a = 0.9

    local width = itemsBox:getWidth()/itemsBox.elementsPerRow
    local x = width * rowElementNumber

    local clipY = math.max(0, y + itemsBox:getYScroll())
    local clipY2 = math.min(itemsBox.height, y + itemsBox:getYScroll() + itemsBox.itemheight)

    -- Border of single item
    itemsBox:drawRectBorder(x, y, width, item.height - 1, a, itemsBox.borderColor.r, itemsBox.borderColor.g, itemsBox.borderColor.b)




    --* USER NAME *--


    -- Items are stored in a table that works as a container, let's unpack them here to make it more readable
    local itemDisplayName = item.item.actualItem:getDisplayName()

    --* ITEM NAME *--
	itemsBox:setStencilRect(x, clipY, width - 1, clipY2 - clipY)
    itemsBox:drawText(itemDisplayName, x + 6, y + 2, 1, 1, 1, a, itemsBox.font)

    --* ITEM COST *--
    local itemData = ShopItemsManager.GetItem(item.item.fullType)

    if itemData == nil then
        itemData = { basePrice = 100, sellMultiplier = 0.5 }
    end

    local price = itemData.basePrice * itemData.sellMultiplier
    local priceStr = "$" .. tostring(price)
    local priceStrY = getTextManager():MeasureStringY(itemsBox.font, priceStr)
    itemsBox:drawText(priceStr, x + 6, y + priceStrY + 2, 1, 1, 1, a, itemsBox.font)
    itemsBox:clearStencilRect()

	itemsBox:repaintStencilRect(x, clipY, width, clipY2 - clipY)

    return y + item.height
end

return RecapScrollKilledPlayersPanel