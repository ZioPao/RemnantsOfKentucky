local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
---------------------------------------


-- TODO Add options here too, like the During Match Panel
-- TODO Add countdown setters




---@class MatchOptionsPanel : ISCollapsableWindow
local MatchOptionsPanel = ISCollapsableWindow:derive("MatchOptionsPanel")

function MatchOptionsPanel.Open(x, y, width, height)
    if MatchOptionsPanel.instance then
        MatchOptionsPanel.instance:close()
    end

    local modal = MatchOptionsPanel:new(x, y, width, height)
    modal:initialise()
    modal:addToUIManager()
    --modal.instance:setKeyboardFocus()

    return modal
end

function MatchOptionsPanel:new(x, y, width, height)
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
    MatchOptionsPanel.instance = o
    return o
end

function MatchOptionsPanel:initialise()
    ISCollapsableWindow.initialise(self)
end

function MatchOptionsPanel:createChildren()
    local btnHeight = 50
    local xPadding = 20
    local btnWidth = self:getWidth() - xPadding * 2
    local yPadding = 10

    local label = ISLabel:new(xPadding, yPadding, 25, getText("IGUI_EFT_AdminPanel_MatchOptions"), 1, 1, 1, 1, UIFont.NewLarge, true)
    label:initialise()
    label:instantiate()
    self:addChild(label)
end

function MatchOptionsPanel:prerender()
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)
end


function MatchOptionsPanel:update()
    ISCollapsableWindow.update(self)
end

function MatchOptionsPanel:render()
    ISCollapsableWindow.render(self)

end

function MatchOptionsPanel:close()
    if self.confirmationPanel then
        self.confirmationPanel:close()
    end
    ISCollapsableWindow.close(self)
end


return MatchOptionsPanel