local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
local ENTRY_HGT = FONT_HGT_MEDIUM + 2 * 2

-- TODO Make it local
ManagePlayersPanel = ISCollapsableWindow:derive("ManagePlayersPanel")

function ManagePlayersPanel.Open(x, y)
    if ManagePlayersPanel.instance then
        ManagePlayersPanel.instance:close()
    end

    local modal = ManagePlayersPanel:new(x, y, 350, 500)
    modal:initialise()
    modal:addToUIManager()
    modal.instance:setKeyboardFocus()

    return modal
end

function ManagePlayersPanel:new(x, y, width, height)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 1 }
    o.width = width
    o.height = height
    o.resizable = false
    o.moveWithMouse = false
    ManagePlayersPanel.instance = o
    return o
end

function ManagePlayersPanel:initialise()
    local top = 40

    local entryHgt = FONT_HGT_SMALL + 2 * 2
    self.filterEntry = ISTextEntryBox:new("Players", 10, top, (self.width - 10 * 2) / 1.5, entryHgt)
    self.filterEntry:initialise()
    self.filterEntry:instantiate()
    self.filterEntry:setClearButton(true)
    self.filterEntry:setText("")
    self:addChild(self.filterEntry)

    self.filterEntry.onTextChange = function()
        self:fillList()
    end

    self.panel = ISTabPanel:new(10, top + entryHgt + 10, (self.width - 10 * 2) / 1.5, self.height + top - 50)
    self.panel:initialise()
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.panel.target = self
    self.panel.equalTabWidth = false
    self.panel.tabTransparency = 0
    self.panel.tabHeight = 0
    self:addChild(self.panel)

    local btnY = self.panel:getHeight() / 2 - top
    local btnX = self.panel:getRight() + 10

    local btnSize = (self:getWidth() - self.panel:getWidth()) - 30 -- You must account for the padding, 10 and -20


    local openIco = getTexture("media/ui/openPanelIcon.png")        -- Document icons created by Freepik - Flaticon - Document
    local refreshListIco = getTexture("media/ui/refreshIcon.png")   -- Refresh icons created by Dave Gandy - Flaticon - Refresh
    local deleteDataIco = getTexture("media/ui/deleteDataIcon.png") -- www.flaticon.com/free-icons/delete Delete icons created by Kiranshastry - Flaticon

    -- Middle button
    self.btnCleanStorage = ISButton:new(btnX, btnY, btnSize, btnSize / 1.5,
        getText("IGUI_AdminPanelBeforeMatch_CleanStorage"), self, ManagePlayersPanel.onClick)
    self.btnCleanStorage.internal = "CLEAN_STORAGE"
    self.btnCleanStorage:setTooltip(getText("IGUI_AdminPanelBeforeMatch_Tooltip_CleanStorage"))
    self.btnCleanStorage:setImage(openIco)
    self.btnCleanStorage.anchorTop = false
    self.btnCleanStorage.anchorBottom = true
    self.btnCleanStorage:initialise()
    self.btnCleanStorage:instantiate()
    self.btnCleanStorage.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self:addChild(self.btnCleanStorage)

    self.btnUnassign = ISButton:new(btnX, btnY - self.btnCleanStorage:getHeight() - 10, btnSize, btnSize / 1.5,
        getText("IGUI_AdminPanelBeforeMatch_Unassign"), self, ManagePlayersPanel.onClick)
    self.btnUnassign.internal = "UNASSIGN"
    self.btnUnassign:setTooltip(getText("IGUI_AdminPanelBeforeMatch_Unassign"))
    self.btnUnassign:setImage(refreshListIco)
    self.btnUnassign.anchorTop = false
    self.btnUnassign.anchorBottom = true
    self.btnUnassign:initialise()
    self.btnUnassign:instantiate()
    self.btnUnassign.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self:addChild(self.btnUnassign)

    self.btnStarterKit = ISButton:new(btnX, btnY + self.btnCleanStorage:getHeight() + 10, btnSize, btnSize / 1.5,
        getText("IGUI_AdminPanelBeforeMatch_StarterKit"), self, ManagePlayersPanel.onClick)
    self.btnStarterKit.internal = "STARTER_KIT"
    self.btnStarterKit:setTooltip(getText("IGUI_AdminPanelBeforeMatch_Tooltip_StarterKit"))
    self.btnStarterKit:setImage(deleteDataIco)
    self.btnStarterKit:setBorderRGBA(1, 1, 1, 1)
    self.btnStarterKit:setTextureRGBA(1, 1, 1, 1)
    self.btnStarterKit.anchorTop = false
    self.btnStarterKit.anchorBottom = true
    self.btnStarterKit:initialise()
    self.btnStarterKit:instantiate()
    self.btnStarterKit.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self:addChild(self.btnStarterKit)



    local xPadding = 20
    local normalBtnWidth = self:getWidth() - xPadding * 2
    local normalBtnHeight = 25

    self.btnWipeEverything = ISButton:new(xPadding, self:getHeight() - normalBtnHeight - 10, normalBtnWidth,
        normalBtnHeight / 1.5, getText("IGUI_AdminPanelBeforeMatch_WipeEverything"), self, ManagePlayersPanel.onClick)
    self.btnWipeEverything.internal = "WIPE_EVERYTHING"
    self.btnWipeEverything:setTooltip(getText("IGUI_AdminPanelBeforeMatch_Tooltip_WipeEverything"))
    self.btnWipeEverything:setImage(deleteDataIco)
    self.btnWipeEverything:setBorderRGBA(1, 1, 1, 1)
    self.btnWipeEverything:setTextureRGBA(1, 1, 1, 1)
    self.btnWipeEverything.anchorTop = false
    self.btnWipeEverything.anchorBottom = true
    self.btnWipeEverything:initialise()
    self.btnWipeEverything:instantiate()
    self.btnWipeEverything.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self:addChild(self.btnWipeEverything)


    self.mainCategory = ManagePlayersScrollingTable:new(0, 0, self.panel.width, self.panel.height, self)
    self.mainCategory:initialise()
    self.panel:addView("Players", self.mainCategory)
    self.panel:activateView("Players")
    self:fillList()
end

function ManagePlayersPanel:fillList()
    local players
    if isClient() then
        players = getOnlinePlayers()
    else
        players = ArrayList.new()
        players:add(getPlayer())
    end

    self.mainCategory:initList(players)
end

function ManagePlayersPanel:prerender()
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)
end

function ManagePlayersPanel:onClick(button)
    if button.internal == 'UNASSIGN' then

    elseif button.internal == 'CLEAN_STORAGE' then

    elseif button.internal == 'STARTER_KIT' then
        -- TODO Give Starter kit to selected player
    elseif button.internal == 'WIPE_EVERYTHING' then

        local function onConfirmWipe()
            print("Wipe")
        end


        local text = " <CENTRE> Are you sure you want to wipe out everything? <LINE> You can't come back from this."
        self.confirmationPanel = ConfirmationPanel.Open(text, self:getX(), self:getY() + self:getHeight() + 20, onConfirmWipe)
    end
end

function ManagePlayersPanel:setKeyboardFocus()
    local view = self.panel:getActiveView()
    if not view then return end
    Core.UnfocusActiveTextEntryBox()
    --view.filterWidgetMap.Type:focus()
end

function ManagePlayersPanel:update()
    ISCollapsableWindow.update(self)
    local selection = self.mainCategory.datas.selected

    self.btnUnassign:setEnable(selection ~= 0)
    self.btnCleanStorage:setEnable(selection ~= 0)
    self.btnStarterKit:setEnable(selection ~= 0)
end

function ManagePlayersPanel:close()
    if self.confirmationPanel then
        self.confirmationPanel:close()
    end
    ISCollapsableWindow.close(self)
end

--************************************************************************--


ManagePlayersScrollingTable = ISPanel:derive("ManagePlayersScrollingTable")

function ManagePlayersScrollingTable:new(x, y, width, height, viewer)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)

    o.listHeaderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.3 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.0 }
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    o.totalResult = 0
    o.viewer = viewer

    ManagePlayersScrollingTable.instance = o
    return o
end

function ManagePlayersScrollingTable:createChildren()
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local bottomHgt = 5 + FONT_HGT_SMALL * 2 + 5 + btnHgt + 20 + FONT_HGT_LARGE + HEADER_HGT + ENTRY_HGT

    self.datas = ISScrollingListBox:new(0, HEADER_HGT, self.width, self.height - bottomHgt + 10)
    self.datas:initialise()
    self.datas:instantiate()
    self.datas.itemheight = FONT_HGT_SMALL + 4 * 2
    self.datas.selected = 0
    self.datas.joypadParent = self
    self.datas.font = UIFont.NewSmall
    self.datas.doDrawItem = self.drawDatas
    self.datas.drawBorder = true
    self.datas:addColumn("", 0)
    self:addChild(self.datas)
end

function ManagePlayersScrollingTable:initList(module)
    self.datas:clear()
    for i = 0, module:size() - 1 do
        local pl = module:get(i)
        local username = pl:getUsername()

        if self.viewer.filterEntry:getInternalText() ~= "" and string.trim(self.viewer.filterEntry:getInternalText()) == nil or string.contains(string.lower(username), string.lower(string.trim(self.viewer.filterEntry:getInternalText()))) then
            self.datas:addItem(username, pl)
        end
    end
end

function ManagePlayersScrollingTable:update()
    self.datas.doDrawItem = self.drawDatas
end

function ManagePlayersScrollingTable:drawDatas(y, item, alt)
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

    -- TODO ADD BALANCE
    local xOffset = 10
    self:drawText(item.text, xOffset, y + 4, 1, 1, 1, a, self.font)
    return y + self.itemheight
end
