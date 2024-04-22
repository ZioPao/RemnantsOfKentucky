local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
local IconButton = require("ROK/UI/BaseComponents/IconButton")

local MatchOptionsPanel = require("ROK/UI/BaseComponents/MatchOptionsPanel")
local ManagePlayersPanel = require("ROK/UI/BeforeMatch/ManagePlayersPanel")
local ModManagementPanel = require("ROK/UI/BeforeMatch/ModManagementPanel")
local PricesEditorPanel = require("ROK/UI/BeforeMatch/PricesEditorPanel")


--------------------------------
local START_MATCH_TEXT = getText("IGUI_EFT_AdminPanel_StartMatch")

local START_MATCH_ICON = getTexture("media/textures/BeforeMatchPanel/StartMatch.png") -- https://www.freepik.com/icon/play_14441317#fromView=family&page=1&position=0&uuid=6c560048-e143-4f62-bae1-92319409fae7


-- -- Base for admin panels

-- This should be the common start for the Admin panels.
---@class BaseAdminPanel : ISCollapsableWindow
local BaseAdminPanel = ISCollapsableWindow:derive("BaseAdminPanel")


---@param x any
---@param y any
---@param width any
---@param height any
---@return BaseAdminPanel
function BaseAdminPanel:new(x, y, width, height)
    ---@type BaseAdminPanel
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.resizable = false

    o.width = width
    o.height = height

    o.variableColor = { r = 0.9, g = 0.55, b = 0.1, a = 1 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 1.0 }
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    o.moveWithMouse = true

    o.isMatchEnded = nil

    BaseAdminPanel.instance = o

    return o
end



function BaseAdminPanel:createChildren()
    ISCollapsableWindow.createChildren(self)

    -- Start from the bottom and og up form that
    local btnHeight = 50
    local xPadding = GenericUI.X_PADDING
    local yPadding = 10
    local y = self:getHeight() - btnHeight - yPadding
    local btnWidth = self:getWidth() - xPadding * 2

    self.btnToggleMatch = IconButton:new(
        xPadding, y, btnWidth, btnHeight,
        START_MATCH_ICON, START_MATCH_TEXT, "START",
        self, self.onClick
    )
    self.btnToggleMatch:initialise()
    self:addChild(self.btnToggleMatch)

    y = y - btnHeight - yPadding * 3 -- More padding from this



    --* Main buttons, ordererd as a grid
    ----------------

    local gridBtnWidth = (btnWidth - xPadding) / 2
    local xRightPadding = self:getWidth() / 2 + xPadding / 2

    -- Top line

    self.btnMatchOptions = ISButton:new(xPadding, y, gridBtnWidth, btnHeight, "", self, self.onClick)
    self.btnMatchOptions.internal = "OPEN_MATCH_OPTIONS"
    self.btnMatchOptions:initialise()
    self.btnMatchOptions:setEnable(true)
    self.btnMatchOptions:setTitle(getText("IGUI_EFT_AdminPanel_MatchOptions"))
    self:addChild(self.btnMatchOptions)

    self.btnManagePlayersOption = ISButton:new(xRightPadding, y, gridBtnWidth, btnHeight, "", self, self.onClick)
    self.btnManagePlayersOption.internal = "OPEN_PLAYERS_OPTIONS"
    self.btnManagePlayersOption:initialise()
    self.btnManagePlayersOption:setEnable(true)
    self.btnManagePlayersOption:setTitle(getText("IGUI_EFT_AdminPanel_ManagePlayers_Title"))
    self:addChild(self.btnManagePlayersOption)

    y = y - btnHeight - yPadding

    -- Bottom Line
    self.btnManagementOption = ISButton:new(xPadding, y, gridBtnWidth, btnHeight, "", self, self.onClick)
    self.btnManagementOption.internal = "OPEN_MANAGEMENT_OPTION"
    self.btnManagementOption:initialise()
    self.btnManagementOption:setEnable(true)
    self.btnManagementOption:setTitle(getText("IGUI_EFT_AdminPanel_ModManagement_Title"))
    self:addChild(self.btnManagementOption)

    self.btnEconomyManagement = ISButton:new(xRightPadding, y, gridBtnWidth, btnHeight, "", self, self.onClick)
    self.btnEconomyManagement.internal = "OPEN_ECONOMY_MANAGEMENT"
    self.btnEconomyManagement:initialise()
    self.btnEconomyManagement:setEnable(true)
    self.btnEconomyManagement:setTitle(getText("IGUI_EFT_AdminPanel_Economy"))
    self:addChild(self.btnEconomyManagement)


    --------------------
    -- INFO PANEL, TOP ONE

    local panelInfoHeight = self:getHeight() / 4

    self.panelInfo = ISRichTextPanel:new(0, 20, self:getWidth(), panelInfoHeight)
    self.panelInfo.autosetheight = false
    self.panelInfo.background = true
    self.panelInfo.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 }
    self.panelInfo.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.panelInfo.marginTop = self.panelInfo:getHeight() / 2
    self.panelInfo:initialise()
    self.panelInfo:paginate()
    self:addChild(self.panelInfo)


    -- local labelWidth = self:getWidth() / 2
    -- local labelHeight = self.panelInfo:getHeight() / 2


    -- -- Top of the panelInfo
    -- self:createIsRichTextPanel("labelInstancesAvailable", "panelInfo", labelWidth / 2, 0, labelWidth, labelHeight,
    --     labelHeight / 4, AVAILABLE_INSTANCES_STR)
    -- -- Bottom of Panel Info
    -- self:createIsRichTextPanel("labelValInstancesAvailable", "panelInfo", labelWidth / 2, labelHeight + yPadding,
    --     labelWidth, labelHeight, 0, "")
end

function BaseAdminPanel:onClick(btn)
    --*Match options
    if btn.internal == "OPEN_MATCH_OPTIONS" then
        GenericUI.ToggleSidePanel(self, MatchOptionsPanel)
        return
    end


    --* Players Options
    if btn.internal == "OPEN_PLAYERS_OPTIONS" then
        GenericUI.ToggleSidePanel(self, ManagePlayersPanel)
        return
    end

    --* Mod management Options
    if btn.internal == "OPEN_MANAGEMENT_OPTION" then
        GenericUI.ToggleSidePanel(self, ModManagementPanel)
        return
    end

    --* Other Options
    if btn.internal == "OPEN_ECONOMY_MANAGEMENT" then
        GenericUI.ToggleSidePanel(self, PricesEditorPanel)
        return
    end

end


function BaseAdminPanel:update()
    ISCollapsableWindow.update(self)
end


function BaseAdminPanel:render()
    ISCollapsableWindow.render(self)
    if self.openedPanel then
        self.openedPanel:setX(self:getRight())
        self.openedPanel:setY(self:getBottom() - self:getHeight())
    end
end




---@param modal ISUIElement
function BaseAdminPanel:setTopPanel(modal)

end


---@param name string
---@param parentName string
---@param x number
---@param y number
---@param width number
---@param height number
---@param marginTop number
---@param text string
function BaseAdminPanel:createIsRichTextPanel(name, parentName, x, y, width, height, marginTop, text)
    self[name] = ISRichTextPanel:new(x, y, width, height)
    self[name].autosetheight = false
    self[name].marginBottom = 0
    self[name].marginTop = marginTop
    self[name].backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self[name].borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self[name]:initialise()
    self[name]:setText(text)
    self[name]:paginate()
    self[parentName]:addChild(self[name])
end

---------
---Opens a panel
---@param type any
---@return ISCollapsableWindow?
function BaseAdminPanel.OnOpenPanel(type)
    if type.instance and type.instance:getIsVisible() then
        type.instance:close()
        ButtonManager["AdminPanel"]:setImage(BUTTONS_DATA_TEXTURES["AdminPanel"].OFF)
        return
    end

    local width = 350 * GenericUI.FONT_SCALE
    local height = 400 * GenericUI.FONT_SCALE

    local x = 100 --getCore():getScreenWidth() / 2 - width
    local y = getCore():getScreenHeight() / 2 - height

    local pnl = type:new(x, y, width, height)
    pnl:initialise()
    pnl:instantiate()
    pnl:addToUIManager()
    pnl:bringToTop()

    ButtonManager["AdminPanel"]:setImage(BUTTONS_DATA_TEXTURES["AdminPanel"].ON)
    return pnl
end

---Closes a panel
---@param type ISCollapsableWindow
---@return boolean
function BaseAdminPanel.OnClosePanel(type)
    if type.instance and type.instance:getIsVisible() then
        type.instance:close()
        return true
    end

    return false
end

return BaseAdminPanel
