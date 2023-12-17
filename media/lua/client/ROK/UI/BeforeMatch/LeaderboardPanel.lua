--[[
    The leaderboard is a special menu that everyone can access from their safehouses.
    It will show a list of all the players who have played on the server, sorted by
    balance on that player account.
]]

local GenericUI = require("ROK/UI/BaseComponents/GenericUI")

-------------------------------------
---@class LeaderboardScrollingTable : ISPanel
local LeaderboardScrollingTable = ISPanel:derive("LeaderboardScrollingTable")

function LeaderboardScrollingTable:new(x, y, width, height, viewer)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)

    o.listHeaderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.3 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.0 }
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    o.totalResult = 0
    o.viewer = viewer

    LeaderboardScrollingTable.instance = o
    return o
end

function LeaderboardScrollingTable:createChildren()
    local btnHgt = math.max(25, GenericUI.SMALL_FONT_HGT + 3 * 2)
    local bottomHgt = 5 + GenericUI.SMALL_FONT_HGT * 2 + 5 + btnHgt + 20 + GenericUI.LARGE_FONT_HGT + GenericUI.HEADER_HGT + GenericUI.ENTRY_HGT

    self.datas = ISScrollingListBox:new(0, GenericUI.HEADER_HGT, self.width, self.height - bottomHgt + 10)
    self.datas:initialise()
    self.datas:instantiate()
    self.datas.itemheight = GenericUI.LARGE_FONT_HGT + 4 * 2
    self.datas.selected = 0
    self.datas.joypadParent = self
    self.datas.font = UIFont.Large
    self.datas.doDrawItem = self.drawDatas
    self.datas.drawBorder = true
    self.datas:addColumn("#", 0)
    self.datas:addColumn("Player", 100)
    self.datas:addColumn("Balance", 400)
    self:addChild(self.datas)
end

---Initialize and sort the list
---@param module table
function LeaderboardScrollingTable:initList(module)
    self.datas:clear()
    if module == nil then return end
    for index, bankAccount in ipairs(module) do
        local username = bankAccount.username
        if self.viewer.filterEntry:getInternalText() ~= "" and string.trim(self.viewer.filterEntry:getInternalText()) == nil or string.contains(string.lower(username), string.lower(string.trim(self.viewer.filterEntry:getInternalText()))) then
            self.datas:addItem(username, bankAccount)
        end
    end
end

function LeaderboardScrollingTable:update()
    self.datas.doDrawItem = self.drawDatas
end

function LeaderboardScrollingTable:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end
    local a = 0.9

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15)
    end
    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.6, 0.5, 0.5)
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)

    local xOffset = 10

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)
    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)

    -- Index
    self:drawText(tostring(item.itemindex), xOffset, y + 4, 1, 1, 1, a, self.font)
    self:clearStencilRect()

    -- Player name
    clipX = self.columns[2].size
    clipX2 = self.columns[3].size
    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.text, self.columns[2].size + xOffset, y + 4, 1, 1, 1, a, self.font)
    self:clearStencilRect()

    -- Balance
    self:drawText("$" .. tostring(item.item.balance), self.columns[3].size + xOffset, y + 4, 1, 1, 1, a, self.font)

    return y + self.itemheight
end

--************************************************************************--

---@class LeaderboardPanel : ISCollapsableWindow
local LeaderboardPanel = ISCollapsableWindow:derive("LeaderboardPanel")

function LeaderboardPanel:new(x, y, width, height)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = { r = 0.4, g = 1, b = 0.4, a = 0.2 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.8 }
    o.resizable = false
    o.moveWithMouse = true

    LeaderboardPanel.instance = o
    return o
end

function LeaderboardPanel:initialise()
    ISCollapsableWindow.initialise(self)

    -- Request all the banks account to fill the leaderboard
    sendClientCommand(EFT_MODULES.Bank, 'TransmitAllBankAccounts', {})
end

function LeaderboardPanel:createChildren()
    ISCollapsableWindow.createChildren(self)
    local yOffset = 30
    local xOffset = 10
    local yMargin = 15
    local entryHgt = GenericUI.SMALL_FONT_HGT + 2 * 10

    self.labelLeaderboard = ISRichTextPanel:new(0, yOffset, self.width, 15)
    self.labelLeaderboard:initialise()
    self.labelLeaderboard.marginTop = 0
    self.labelLeaderboard.autosetheight = true
    self.labelLeaderboard.background = false
    self.labelLeaderboard.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.labelLeaderboard.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.labelLeaderboard:setText(" <CENTRE> <H1> " .. getText("IGUI_EFT_Leaderboard_Title"))
    self.labelLeaderboard:paginate()
    self:addChild(self.labelLeaderboard)

    yOffset = yOffset + self.labelLeaderboard:getHeight() + yMargin

    self.filterEntry = ISTextEntryBox:new(getText("IGUI_EFT_Leaderboard_Players"), xOffset, yOffset, self:getWidth() - 10 * 2, entryHgt)
    self.filterEntry:initialise()
    self.filterEntry:instantiate()
    self.filterEntry:setClearButton(true)
    self.filterEntry:setText("")
    self:addChild(self.filterEntry)

    ---@diagnostic disable-next-line: duplicate-set-field
    self.filterEntry.onTextChange = function()
        self:fillList()
    end

    yOffset = yOffset + self.filterEntry:getHeight() + yMargin

    self.panel = ISTabPanel:new(xOffset, yOffset, self:getWidth() - xOffset * 2, self:getHeight() - yOffset)
    self.panel:initialise()
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.panel.target = self
    self.panel.equalTabWidth = false
    self.panel.tabTransparency = 0
    self.panel.tabHeight = 0
    self:addChild(self.panel)
    self.mainCategory = LeaderboardScrollingTable:new(0, 0, self.panel.width, self.panel.height, self)
    self.mainCategory:initialise()
    self.panel:addView("", self.mainCategory)
    self.panel:activateView("")
    self:fillList()
end

function LeaderboardPanel:fillList()
    self.mainCategory:initList(LeaderboardPanel.bankAccounts)
end

function LeaderboardPanel:prerender()
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)
end

function LeaderboardPanel:setKeyboardFocus()
    local view = self.panel:getActiveView()
    if not view then return end
    Core.UnfocusActiveTextEntryBox()
    --view.filterWidgetMap.Type:focus()
end

function LeaderboardPanel:close()
    ISCollapsableWindow.close(self)
end

--************************************************************************--
function LeaderboardPanel.Open(x, y)
    -- TODO Find a better way to handle icons
    if LeaderboardPanel.instance and LeaderboardPanel.instance:getIsVisible() then
        LeaderboardPanel.instance:close()
        ButtonManager["Leaderboard"]:setImage(BUTTONS_DATA_TEXTURES["Leaderboard"].OFF)
        return
    end

    -- TODO Too big in some parts
    local width = 400 * GenericUI.FONT_SCALE
    local height = 600 * GenericUI.FONT_SCALE

    local modal = LeaderboardPanel:new(x, y, width, height)
    modal:initialise()
    modal:addToUIManager()
    modal.instance:setKeyboardFocus()
    ButtonManager["Leaderboard"]:setImage(BUTTONS_DATA_TEXTURES["Leaderboard"].ON)

    return modal
end
function LeaderboardPanel.SetBankAccounts(accounts)

    if LeaderboardPanel.instance == nil then return end

    debugPrint("Setting bank accounts to LeaderboardPanel")

    local sortedAccounts = {}
    for _, v in pairs(accounts) do
        table.insert(sortedAccounts, v)
    end

    local function SortByBalance(a,b)
        return a.balance > b.balance
    end

    table.sort(sortedAccounts, SortByBalance)


    LeaderboardPanel.bankAccounts = sortedAccounts
        --debugPrint(sortedAccounts)
        --PZEFT_UTILS.PrintTable(sortedAccounts)
    
end


return LeaderboardPanel
