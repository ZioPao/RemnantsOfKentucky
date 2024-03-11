-- Left Icon
-- Right Button

---@class IconButton : ISPanel
local IconButton = ISPanel:derive("IconButton")

---@param x number
---@param y number
---@param width number
---@param height number
---@param icon Texture
---@param text string
---@param internal string
---@return IconButton
function IconButton:new(x, y, width, height, icon, text, internal, param, onClick)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    self.text = text
    self.internal = internal
    self.icon = icon

    self.param = param
    self.onClick = onClick

    ---@cast o IconButton
    return o
end

function IconButton:initialise()

    -- local elementHeight = 50
    -- local xPadding = 10
    -- local yPadding = (self:getHeight() + elementHeight)/2
    local btnWidth = self:getWidth()/2


    -- Icon is gonna be a square, 50x50
    self.icon = ISImage:new(0, 0, 100, 100, self.texture)
    self.icon:initialise()
    self.icon:instantiate()
    self:addChild(self.icon)

    self.btn = ISButton:new(self.icon:getRight() + 5, 0, btnWidth, 20, "", self.param, self.onClick)
    self.btn.internal = self.internal
    self.btn:initialise()
    self.btn:setTitle(self.text)
    self:addChild(self.btn)
end

function IconButton:setEnable(val)
    self.btn:setEnable(val)
end

function IconButton:setTitle(title)
    self.btn:setTitle(title)
end



return IconButton