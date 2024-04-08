---@class AdminTopPanel : ISPanel
---@field elementHeight number
---@field lastY number
local AdminTopPanel = ISPanel:derive("AdminTopPanel")


---@return AdminTopPanel
function AdminTopPanel:new(x, y, width, height, elementHeight)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o:initialise()
    --o.elementWidth = elementWidth
    o.elementHeight = elementHeight
    o.lastY = y

    ---@cast o AdminTopPanel
    return o
end


---@param name string
---@param x number
---@param y number
---@param width number
---@param height number
---@param marginTop number
---@param text string
function AdminTopPanel:createIsRichTextPanel(name, x, y, width, height, marginTop, text)
    self[name] = ISRichTextPanel:new(x, y, width, height)
    self[name].autosetheight = false
    self[name].marginBottom = 0
    self[name].marginTop = marginTop
    self[name].backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self[name].borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self[name]:initialise()
    self[name]:setText(text)
    self[name]:paginate()
    self:addChild(self[name])
end


---@param name string
function AdminTopPanel:createRow(name)
    local xPadding = 15


    -- Label
    local labelName = name .. "Label"
    local labelText = getText("IGUI_EFT_AdminPanel_Top_" .. name:gsub("^%l", string.upper))

    local label = ISLabel:new(xPadding, self.lastY, self.elementHeight, labelText, 1, 1, 1, 1, UIFont.NewLarge, true)
    label:initialise()
    label:instantiate()

    self[labelName] = label
    self:addChild(self[labelName])


    -- Val label
    local labelValName = name .. "LabelVal"

    local xPos = self:getWidth() - xPadding

    local labelVal = ISLabel:new(xPos, self.lastY, self.elementHeight, "", 1,1,1,1, UIFont.NewLarge, false)
    labelVal:initialise()
    labelVal:instantiate()

    self[labelValName] = labelVal
    self:addChild(self[labelValName])

    self.lastY = self.lastY + self.elementHeight

end



return AdminTopPanel