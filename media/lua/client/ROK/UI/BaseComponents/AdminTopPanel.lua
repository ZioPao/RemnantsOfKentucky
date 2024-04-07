local BeforeTopPanel = ISPanel:derive("AdminTopPanel")


---@param name string
---@param parentName string
---@param x number
---@param y number
---@param width number
---@param height number
---@param marginTop number
---@param text string
function BeforeTopPanel:createIsRichTextPanel(name, parentName, x, y, width, height, marginTop, text)
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