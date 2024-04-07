local GenericUI = require("ROK/UI/BaseComponents/GenericUI")


-- -- Base for admin panels

-- This should be the common start for the Admin panels.
---@class BaseAdminPanel : ISCollapsableWindow
local BaseAdminPanel = ISCollapsableWindow:derive("BaseAdminPanel")


function BaseAdminPanel:new(x, y, width, height)
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

    --DuringMatchAdminPanel.instance = o
    return o
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
