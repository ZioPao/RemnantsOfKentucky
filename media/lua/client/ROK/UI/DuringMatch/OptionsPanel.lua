
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_SCALE = FONT_HGT_SMALL / 16
if FONT_SCALE < 1 then
    FONT_SCALE = 1
end

---@class OptionsPanel : ISCollapsableWindow
---@field options table
OptionsPanel = ISCollapsableWindow:derive("OptionsPanel")

function OptionsPanel:new(x, y, width, height)
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
    o.counterOptions = 0


    OptionsPanel.instance = o
    return o
end

function OptionsPanel:createChildren()
    ISCollapsableWindow.createChildren(self)
    self:createHorizontalPanel("testPanel", "Zombie multiplier")
    self:createHorizontalPanel("testPanel2", "Zombie multiplier2")
    self:createHorizontalPanel("testPanel3", "Zombie multiplier3")

    local xPadding = 20
    local yPadding = 20
    local btnWidth = self:getWidth() - xPadding * 2
    local btnHeight = 25

    local y = self:getHeight() - btnHeight - yPadding

    self.btnApply = ISButton:new(xPadding, y, btnWidth, btnHeight,
        getText("IGUI_EFT_AdminPanel_Apply"), self, self.onClick)
    self.btnApply.internal = "APPLY"
    self.btnApply:initialise()
    self:addChild(self.btnApply)
end

function OptionsPanel:onClick(btn)
    if btn.internal ~= "APPLY" then return end

    for i=1, #self.options do
        -- get option and apply it accordingly. Send it to the server
    end

end

---@param name string
---@param textLabel string
function OptionsPanel:createHorizontalPanel(name, textLabel)
    local height = 50
    local counter = #self.options + 1

    local y = height * counter
    if counter == 1 then
        local th = self:titleBarHeight()
        y = y + th
    end

    self[name] = ISPanel:new(0, y, self.width, height)
    self[name]:initialise()
    self:addChild(self[name])

    -- Label
    local xPadding = 10
    self[name].label = ISLabel:new(xPadding, 4, height, textLabel, 1, 1, 1, 1, UIFont.NewMedium, true)
    self[name].label:initialise()
    self[name].label:instantiate()
    self[name]:addChild(self[name].label)

    -- Option
    local optionWidth = 50
    self[name].option = ISTextEntryBox:new("", self.width - optionWidth, 0, optionWidth, height)
    self[name].option:initialise()
    self[name].option:instantiate()
    self[name].option:setClearButton(false)
    self[name].option:setText("")
    self[name]:addChild(self[name].option)


    table.insert(self.options, self[name])

end

------------------

function OptionsPanel.Open(x,y)
    local pnl = OptionsPanel:new(x, y, 400, 600)
    pnl:initialise()
    pnl:instantiate()
    pnl:addToUIManager()
    pnl:bringToTop()
end

function OptionsPanel.Close()
    OptionsPanel.instance:close()
end