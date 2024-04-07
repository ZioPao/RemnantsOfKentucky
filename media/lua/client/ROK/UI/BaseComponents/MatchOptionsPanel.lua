local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
---------------------------------------


-- TODO Add options here too, like the During Match Panel
-- TODO Add countdown setters
local optionsReferenceTable = {

    -- MATCH
    ZombieSpawnMultiplier = {
        panelName = "ZombieSpawnMultiplier",
        title = "Zombie Spawn Multiplier",
        setCommand = "SetZombieSpawnMultiplier",
        askCommand = "SendZombieSpawnMultiplier"
    },

}


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

function MatchOptionsPanel.GetOptionsReference()
    return optionsReferenceTable
end

-------------------------

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

    self.counterOptions = 0
    self.options = {}
end

function MatchOptionsPanel:createChildren()
    local btnHeight = 50
    local xPadding = GenericUI.X_PADDING
    local elementWidth = self:getWidth() - xPadding * 2
    local yPadding = 10

    self.label = ISLabel:new(xPadding, yPadding, 25, getText("IGUI_EFT_AdminPanel_MatchOptions"), 1, 1, 1, 1,
        UIFont.NewLarge, true)
    self.label:initialise()
    self.label:instantiate()
    self:addChild(self.label)


    local xHorizPanel = xPadding
    local yHorizPanel = self.label:getBottom() + yPadding

    for k, v in pairs(optionsReferenceTable) do
        self:createHorizontalPanel(
            xHorizPanel, yHorizPanel, elementWidth,
            k, v.title, v.setCommand, v.askCommand
        )
    end

    local yBtnApply = self:getHeight() - btnHeight - yPadding

    self.btnApply = ISButton:new(
        xPadding, yBtnApply, elementWidth, btnHeight,
        getText("IGUI_EFT_AdminPanel_Apply"), self, self.onClick)
    self.btnApply.internal = "APPLY"
    self.btnApply:initialise()
    self:addChild(self.btnApply)
end

---@param startY number
---@param name string
---@param textLabel string
---@param setCommand string
---@param askCommand string
function MatchOptionsPanel:createHorizontalPanel(startX, startY, width, name, textLabel, setCommand, askCommand)
    --local height = 50
    local counter = #self.options + 1

    local fontHgtSmall = GenericUI.SMALL_FONT_HGT
    local height = fontHgtSmall + 2 * 2

    local y = startY + (height * counter)
    if counter == 1 then
        local th = self:titleBarHeight()
        y = y + th
    end

    self[name] = ISPanel:new(startX, y, width, height)
    self[name]:initialise()
    self:addChild(self[name])

    -- Label
    local xPadding = GenericUI.X_PADDING
    self[name].label = ISLabel:new(xPadding, 0, height, textLabel, 1, 1, 1, 1, UIFont.Small, true)
    self[name].label:initialise()
    self[name].label:instantiate()
    self[name]:addChild(self[name].label)

    -- Option
    local function OnEntryChange(entry)
        local text = entry:getInternalText()
        entry:setValid(text ~= nil and text ~= "" and text ~= "-" and text ~= "0")
    end

    local optionWidth = 25
    --local inset = 2
    --local optionY = self:getHeight() - 8 - inset - height


    self[name].entry = ISTextEntryBox:new("", width - optionWidth, 0, optionWidth, height)
    self[name].entry:initialise()
    self[name].entry:instantiate()
    self[name].entry:setClearButton(false)
    self[name].entry.font = UIFont.Small
    self[name].entry:setText("")
    self[name].entry:setOnlyNumbers(true)
    self[name].entry:setMaxTextLength(1)
    self[name].entry.onTextChange = OnEntryChange
    self[name].entry:setEditable(false) -- By default it's not enabled, until we get the ok from the server
    self[name].entry:setHasFrame(false)
    self[name].entry:setAnchorTop(false)
    self[name].entry:setAnchorBottom(true)
    self[name].entry:setAnchorRight(true)
    self[name].entry.syncedWithServer = false
    self[name]:addChild(self[name].entry)
    self[name].referencedCommand = setCommand
    sendClientCommand(EFT_MODULES.Match, askCommand, {})


    table.insert(self.options, self[name])
end

function MatchOptionsPanel:prerender()
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)
end

function MatchOptionsPanel:update()
    ISCollapsableWindow.update(self)

    -- Check if all the options are valid or not
    local canApply = true

    for i = 1, #self.options do
        local opt = self.options[i]
        -- Horrendous workaround, but since setValid is not really setting anything, this will do.
        if opt.entry.borderColor.r == 0.7 then
            canApply = false
            break
        end
    end

    self.btnApply:setEnable(canApply)
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
