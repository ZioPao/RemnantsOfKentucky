-- Left Icon
-- Right Button

---@class IconButton : ISPanel
---@field texture Texture
local IconButton = ISPanel:derive("IconButton")

---@param x number
---@param y number
---@param width number
---@param height number
---@param texture Texture
---@param text string
---@param internal string
---@return IconButton
function IconButton:new(x, y, width, height, texture, text, internal, param, onClick)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    self.text = text
    self.internal = internal
    self.texture = texture

    self.param = param
    self.onClick = onClick

    ---@cast o IconButton
    return o
end

function IconButton:prerender()
    ISPanel.prerender(self)
    --self:drawTextureScaled(self.icon, 0, 0, 32, 32, 1, 1, 1, 1)
end

function IconButton:initialise()
    local elementHeight = self:getHeight()
    local xPadding = elementHeight/6

    -- Icon is gonna be a square, 50x50
    self.icon = ISImage:new(xPadding, xPadding, elementHeight, elementHeight, self.texture)
    self.icon.scaledWidth = elementHeight * 0.64
	self.icon.scaledHeight = elementHeight * 0.64
    self.icon:setColor(1,1,1)
    self.icon:initialise()
    self.icon:instantiate()
    self:addChild(self.icon)


    local btnWidth = self:getWidth() - elementHeight
    self.btn = ISButton:new(elementHeight, 0, btnWidth, elementHeight, "", self.param, self.onClick)
    self.btn.internal = self.internal
    self.btn:initialise()
    self.btn:setTitle(self.text)
    self:addChild(self.btn)
end


--* Setters
function IconButton:setEnable(val)
    self.btn:setEnable(val)
end

function IconButton:setTitle(title)
    self.btn:setTitle(title)
end

function IconButton:setInternal(internal)
    self.btn.internal = internal
end

---@param texture Texture
function IconButton:setTexture(texture)
    self.icon.texture = texture
end

--* Getters

function IconButton:getInternal()
    return self.btn.internal
end



return IconButton