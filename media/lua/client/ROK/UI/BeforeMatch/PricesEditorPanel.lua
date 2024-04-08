local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
local ConfirmationPanel = require("ROK/UI/ConfirmationPanel")
local ShopItemsManager = require("ROK/ShopItemsManager")

---------------------------------------

local APPLY_ICON = getTexture("media/textures/BeforeMatchPanel/Apply.png")  -- https://www.freepik.com/icon/close_14440874#fromView=family&page=1&position=0&uuid=e818dfad-684a-4567-9aca-43ed2667f4e1
local REFRESH_ICON = getTexture("media/textures/BeforeMatchPanel/Loop.png") -- https://www.freepik.com/icon/rotated_14441036#fromView=family&page=1&position=3&uuid=135de5a3-1019-46dd-bbef-fdbb2fd5b027

-------------------------------


---@class PricesEditorScrollingTable : ISPanel
---@field datas ISScrollingListBox
local PricesEditorScrollingTable = ISPanel:derive("PricesEditorScrollingTable")

---@param x number
---@param y number
---@param width number
---@param height number
---@param viewer any
---@return PricesEditorScrollingTable
function PricesEditorScrollingTable:new(x, y, width, height, viewer)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)

    o.listHeaderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.3 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.0 }
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    o.totalResult = 0
    o.viewer = viewer
    ---@cast o PricesEditorScrollingTable
    PricesEditorScrollingTable.instance = o
    return o
end

function PricesEditorScrollingTable:createChildren()
    -- local btnHgt = math.max(25, GenericUI.SMALL_FONT_HGT + 3 * 2)
    -- local bottomHgt = 5 + GenericUI.SMALL_FONT_HGT * 2 + 5 + btnHgt + 20 + GenericUI.LARGE_FONT_HGT + GenericUI.HEADER_HGT + GenericUI.ENTRY_HGT

    self.datas = ISScrollingListBox:new(0, GenericUI.HEADER_HGT, self.width, self.height - GenericUI.HEADER_HGT)
    self.datas:initialise()
    self.datas:instantiate()
    self.datas.itemheight = GenericUI.SMALL_FONT_HGT + 4 * 2
    self.datas.selected = 0
    self.datas.joypadParent = self
    self.datas.font = UIFont.NewSmall
    self.datas.doDrawItem = self.drawDatas
    self.datas.drawBorder = true


    self.datas:addColumn("FullType", 0)
    self.datas:addColumn("Tag", self.width/2)
    self.datas:addColumn("Price", self.width - 50)
    self:addChild(self.datas)
end

---@param shopItemsTable shopItemsTable
function PricesEditorScrollingTable:initList(shopItemsTable)
    self.datas:clear()

    for itemFullType, shopItemElement in pairs(shopItemsTable.items) do
        if self.viewer.filterEntry:getInternalText() ~= "" and string.trim(self.viewer.filterEntry:getInternalText()) == nil or string.contains(string.lower(itemFullType), string.lower(string.trim(self.viewer.filterEntry:getInternalText()))) then
            self.datas:addItem(itemFullType, shopItemElement)
        end
    end
end

function PricesEditorScrollingTable:update()
    self.datas.doDrawItem = self.drawDatas
end

---@param y any
---@param item {index : number, text : string, item : shopItemElement}
---@param alt any
---@return unknown
function PricesEditorScrollingTable:drawDatas(y, item, alt)
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

    local xOffset = 5

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.text, xOffset, y + 4, 1, 1, 1, a, self.font)
    self:clearStencilRect()


    local tag = item.item.tag --GetTag(item.item.tags)

    clipX = self.columns[2].size
    clipX2 = self.columns[3].size
    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(tag, self.columns[2].size + xOffset + 4, y + 4, 1, 1, 1, a, self.font)
    self:clearStencilRect()



    self:drawText(tostring(item.item.basePrice), self.columns[3].size + xOffset + 4, y + 4, 1, 1, 1, a, self.font)



    return y + self.itemheight
end

--************************************************************************--
---@class PricesEditorPanel : ISCollapsableWindow
local PricesEditorPanel = ISCollapsableWindow:derive("PricesEditorPanel")


-- PricesEditorPanel.Open(0, 0, 500, 500)
function PricesEditorPanel.Open(x, y, width, height)
    if PricesEditorPanel.instance then
        PricesEditorPanel.instance:close()
    end

    local modal = PricesEditorPanel:new(x, y, width + 350, height)
    modal:initialise()
    modal:addToUIManager()
    modal.instance:setKeyboardFocus()

    return modal
end

function PricesEditorPanel.Close()
    if PricesEditorPanel.instance then
        PricesEditorPanel.instance:close()
    end
end

function PricesEditorPanel:new(x, y, width, height)
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
    PricesEditorPanel.instance = o
    return o
end

---@return shopItemElement
function PricesEditorPanel:getSelectedItem()
    local currSelId = self.mainCategory.datas.selected

    ---@type shopItemElement
    local selection = self.mainCategory.datas.items[currSelId].item
    return selection
end

function PricesEditorPanel:onTagChange()
    local item = self:getSelectedItem()

    local selectedTag = self.comboTag:getOptionText(self.comboTag.selected)

    item.tag = selectedTag
end

function PricesEditorPanel:createChildren()
    local xPadding = GenericUI.X_PADDING
    local yPadding = 10

    self.label = ISLabel:new(xPadding, yPadding, 25, getText("IGUI_EFT_AdminPanel_Economy"), 1, 1, 1, 1, UIFont.NewLarge,
        true)
    self.label:initialise()
    self.label:instantiate()
    self:addChild(self.label)

    local y = self.label:getBottom() + yPadding * 2
    local leftSideWidth = (self:getWidth() - xPadding * 2) / 1.25

    local entryHgt = GenericUI.SMALL_FONT_HGT + 2 * 2

    self.filterEntry = ISTextEntryBox:new("Players", 10, y, leftSideWidth, entryHgt)
    self.filterEntry:initialise()
    self.filterEntry:instantiate()
    self.filterEntry:setClearButton(true)
    self.filterEntry:setText("")
    self:addChild(self.filterEntry)

    ---@diagnostic disable-next-line: duplicate-set-field
    self.filterEntry.onTextChange = function()
        self:fillList()
    end

    y = y + self.filterEntry:getHeight() + yPadding
    local panelHeight = self:getHeight() - self.filterEntry:getBottom() - yPadding * 2

    self.panel = ISTabPanel:new(xPadding, y, leftSideWidth, panelHeight)
    self.panel:initialise()
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.panel.target = self
    self.panel.equalTabWidth = false
    self.panel.tabTransparency = 0
    self.panel.tabHeight = 0
    self:addChild(self.panel)

    self.mainCategory = PricesEditorScrollingTable:new(0, 0, leftSideWidth, panelHeight, self)
    self.mainCategory:initialise()
    self.panel:addView("", self.mainCategory)
    self.panel:activateView("")
    self:fillList()


    ---------------------------------
    -- Buttons

    local btnY = self.filterEntry:getY()
    local btnX = self.panel:getRight() + 10

    local btnWidth = (self:getWidth() - self.panel:getWidth()) - xPadding * 3
    local btnHeight = 64


    self.btnRefresh = ISButton:new(
        btnX, btnY, btnWidth, btnHeight,
        "", self, PricesEditorPanel.onClick
    )
    self.btnRefresh.internal = "REFRESH"
    self.btnRefresh:setImage(REFRESH_ICON)
    self.btnRefresh:setTooltip(getText("IGUI_EFT_AdminPanel_Refresh"))
    self.btnRefresh:initialise()
    self.btnRefresh:instantiate()
    self.btnRefresh.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self:addChild(self.btnRefresh)


    local editY = self:getHeight() - btnHeight - yPadding

    -- FROM THE BOTTOM
    self.btnApply = ISButton:new(
        btnX, editY, btnWidth, btnHeight,
        "", self, PricesEditorPanel.onClick
    )

    self.btnApply.internal = "APPLY"
    self.btnApply:setImage(APPLY_ICON)
    self.btnApply:setTooltip(getText("IGUI_EFT_AdminPanel_Apply"))
    self.btnApply:initialise()
    self.btnApply:instantiate()
    self.btnApply.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self:addChild(self.btnApply)


    -- FROM THE MIDDLE -> BOTTOM
    local labelHgt = getTextManager():getFontHeight(UIFont.Large) + 8 * 2

    editY = self:getHeight() / 2 + entryHgt + yPadding

    self.labelPrice = ISLabel:new(btnX, editY, labelHgt, "Price", 1, 1, 1, 1, UIFont.Large, true)
    self.labelPrice:initialise()
    self:addChild(self.labelPrice)

    editY = editY + entryHgt + yPadding * 2

    self.entryPrice = ISTextEntryBox:new("", btnX, editY, btnWidth, entryHgt)
    self.entryPrice:initialise()
    self.entryPrice:instantiate()
    self.entryPrice:setClearButton(false)
    self.entryPrice.font = UIFont.Small
    self.entryPrice.onTextChange = function()
        local item = self:getSelectedItem()
        local newPrice = tonumber(self.entryPrice:getInternalText())
        if newPrice then
            item.basePrice = newPrice
        end
    end
    self.entryPrice:setText("")
    self.entryPrice:setOnlyNumbers(true)
    self.entryPrice:setHasFrame(false)
    self.entryPrice:setAnchorTop(false)
    self.entryPrice:setAnchorBottom(true)
    self.entryPrice:setAnchorRight(true)
    self:addChild(self.entryPrice)

    -- FROM THE MIDDLE -> TOP
    editY = self:getHeight() / 2 - entryHgt - yPadding

    self.comboTag = ISComboBox:new(btnX, editY, btnWidth, entryHgt, self, self.onTagChange)
    self.comboTag:initialise()
    self.comboTag:instantiate()
    --self.comboTag.noSelectionText("SELECT A TAG")
    self.comboTag:setAnchorLeft(false)
    self:addChild(self.comboTag)

    for i = 1, #PZ_EFT_CONFIG.Shop.tags do
        self.comboTag:addOption(PZ_EFT_CONFIG.Shop.tags[i])
    end

    editY = editY - entryHgt - yPadding * 2

    self.labelTag = ISLabel:new(btnX, editY, labelHgt, "Tag", 1, 1, 1, 1, UIFont.Large, true)
    self.labelTag:initialise()
    self:addChild(self.labelTag)
end

function PricesEditorPanel:fillList()
    local shopItems = ShopItemsManager.GetShopItemsData()
    self.mainCategory:initList(shopItems)
end

function PricesEditorPanel:prerender()
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)
end

function PricesEditorPanel:onClick(button)
    if button.internal == 'REFRESH' then
        sendClientCommand(EFT_MODULES.Shop, 'ReloadData', {})
        self.mainCategory.datas:clear() -- Empty for now, until we get the new moddata

    elseif button.internal == 'APPLY' then
        local confY = self:getY() + self:getHeight() + 20
        local text = "Are you sure you want to apply these prices?"
        self.confirmationPanel = ConfirmationPanel.Open(text, self:getX(), confY, nil,
            function()
                -- Send new JSON to server
                -- Get items from list, could be filtered
                local itemsData = ShopItemsManager.GetShopItemsData().items
                local modifiedItems = self.mainCategory.datas.items
                local cleanedData = {}
                for k, v in pairs(itemsData) do
                    local valToApply

                    if modifiedItems[k] then
                        valToApply = modifiedItems[k]
                    else
                        valToApply = v
                    end

                    local tab = {
                        fullType = valToApply.fullType,
                        tag = valToApply.tag,
                        basePrice = valToApply.basePrice
                    }
                    table.insert(cleanedData, tab)
                end

                sendClientCommand(EFT_MODULES.Shop, 'OverrideShopItems', { items = cleanedData })
            end)
    end
end


local function UpdateListAfterUpdate(key)
    if key ~= EFT_ModDataKeys.SHOP_ITEMS then return end
    if PricesEditorPanel.instance and PricesEditorPanel.instance:getIsVisible() then
        PricesEditorPanel.instance:fillList()
    end
end

Events.PZEFT_ClientModDataReady.Add(UpdateListAfterUpdate)


function PricesEditorPanel:setKeyboardFocus()
    local view = self.panel:getActiveView()
    if not view then return end
    Core.UnfocusActiveTextEntryBox()
    --view.filterWidgetMap.Type:focus()
end

function PricesEditorPanel:update()
    ISCollapsableWindow.update(self)

    local currSelId = self.mainCategory.datas.selected
    if currSelId ~= self.prevSelId then
        local selection = self.mainCategory.datas.items[currSelId]
        if selection and selection.item then
            ---@type shopItemElement
            local item = selection.item
            -- Send to combobox and price entry
            local tag = item.tag --GetTag(selection.tags)
            self.comboTag:select(tag)

            local price = tostring(item.basePrice)
            self.entryPrice:setText(price)
        end
    end

    self.prevSelId = currSelId
end

function PricesEditorPanel:render()
    ISCollapsableWindow.render(self)

    if self.confirmationPanel then
        local confY = self:getY() + self:getHeight() + 20
        local confX = self:getX()
        self.confirmationPanel:setX(confX)
        self.confirmationPanel:setY(confY)
    end
end

function PricesEditorPanel:close()
    if self.confirmationPanel then
        self.confirmationPanel:close()
    end
    ISCollapsableWindow.close(self)
end

return PricesEditorPanel
