
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_SCALE = FONT_HGT_SMALL / 16
if FONT_SCALE < 1 then
    FONT_SCALE = 1
end


local optionsReferenceTable = {
    ZombieSpawnMultiplier = {title = "Zombie Spawn Multiplier", command = "SetZombieSpawnMultiplier"},
}


---@alias optionType {label : ISLabel, entry : ISTextEntryBox, referencedCommand : string} This is ISPanel


---@class OptionsPanel : ISCollapsableWindow
---@field options table<integer, optionType>
local OptionsPanel = ISCollapsableWindow:derive("OptionsPanel")

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

function OptionsPanel:initialise()
    ISCollapsableWindow.initialise(self)

    self.counterOptions = 0
    self.options = {}

    -- TODO Fetch config from server
end
function OptionsPanel:createChildren()
    ISCollapsableWindow.createChildren(self)

    for k,v in pairs(optionsReferenceTable) do
        self:createHorizontalPanel(k, v.title, v.command)
    end

    local xPadding = 20
    local yPadding = 20
    local btnWidth = self:getWidth() - xPadding * 2
    local btnHeight = 25

    local y = self:getHeight() - btnHeight - yPadding

    self.btnApply = ISButton:new(xPadding, y, btnWidth, btnHeight, getText("IGUI_EFT_AdminPanel_Apply"), self, self.onClick)
    self.btnApply.internal = "APPLY"
    self.btnApply:initialise()
    self:addChild(self.btnApply)

end

function OptionsPanel:onClick(btn)
    if btn.internal ~= "APPLY" then return end

    for i=1, #self.options do
        -- get option and apply it accordingly. Send it to the server
        local optVal = self.options[i].entry:getInternalText()
        local command = self.options[i].referencedCommand
        sendClientCommand(EFT_MODULES.Match, command, {val = optVal})
    end

end

---@param name string
---@param textLabel string
---@param command string
function OptionsPanel:createHorizontalPanel(name, textLabel, command)
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
    self[name].entry = ISTextEntryBox:new("", self.width - optionWidth, 0, optionWidth, height)
    self[name].entry:initialise()
    self[name].entry:instantiate()
    self[name].entry:setClearButton(false)

    -- TODO Set Text from values got from the server
    -- TODO We need a reference to the setting on the server

    self[name].entry:setText("")
    self[name]:addChild(self[name].entry)

    self[name].referencedCommand = command

    table.insert(self.options, self[name])

end

------------------

function OptionsPanel.Open(x,y)
    local pnl = OptionsPanel:new(x, y, 400, 600)
    pnl:initialise()
    pnl:instantiate()
    pnl:addToUIManager()
    pnl:bringToTop()

    return pnl
end

function OptionsPanel.Close()
    OptionsPanel.instance:close()
end

return OptionsPanel