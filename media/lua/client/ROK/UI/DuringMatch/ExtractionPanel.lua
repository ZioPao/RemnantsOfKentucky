local ExtractionHandler = require("ROK/ExtractionHandler")


---@class ExtractionPanel : ISPanel
local ExtractionPanel = ISPanel:derive("ExtractionPanel")
--TODO Add OnResolutionChange event

---Starts a new Extraction panel
---@param x number
---@param y number
---@param width number
---@param height number
---@return ISPanel
function ExtractionPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o:initialise()
    ExtractionPanel.instance = o
    return o
end

function ExtractionPanel:createChildren()
    ISPanel.createChildren(self)
    self.borderColor = { r = 1, g = 0, b = 0, a = 1 }
    local yPadding = 15
    local xPadding = 15

    local btnWidth = self:getWidth() - xPadding * 2
    local btnHeight = self:getHeight() - yPadding * 2

    self.btnExtract = ISButton:new(xPadding, yPadding, btnWidth, btnHeight, "EXTRACT", self, self.runExtractionMethod)
    self.btnExtract.internal = "EXTRACT"
    self.btnExtract:setFont(UIFont.Large)
    self.btnExtract:initialise()
    self.btnExtract.borderColor = { r = 1, g = 0, b = 0, a = 0.8 }
    self.btnExtract:setEnable(true)
    self:addChild(self.btnExtract)
end

function ExtractionPanel:runExtractionMethod()
    self.btnExtract:setEnable(false)
    ExtractionHandler.DoExtraction()
end

---Set the text that will appear in the button
---@param title string
function ExtractionPanel:setExtractButtonTitle(title)
    self.btnExtract:setTitle(title)
end


---comment
---@return {x : number, y : number}
function ExtractionPanel.GetPosition()
    local x = TimePanel.instance:getAbsoluteX()
    local y = TimePanel.instance:getAbsoluteY() - TimePanel.instance:getHeight() -  50

    return {x=x, y=y}
end
function ExtractionPanel.Toggle()
    if ExtractionPanel.instance == nil then
        local width = 300
        local height = 100

        -- Should be just up the timer
        local pos = ExtractionPanel.GetPosition()
        local panel = ExtractionPanel:new(pos.x, pos.y, width, height)
        panel:initialise()
        panel:addToUIManager()
        panel:bringToTop()
    else
        ExtractionPanel.instance:close()
        ExtractionPanel.instance = nil
    end
end

function ExtractionPanel.Open()
    local width = 300
    local height = 100
    local pos = ExtractionPanel.GetPosition()
    if ExtractionPanel.instance == nil then
        local panel = ExtractionPanel:new(pos.x, pos.y, width, height)
        panel:initialise()
        panel:addToUIManager()
        panel:bringToTop()
    end

end

function ExtractionPanel.Close()
    if ExtractionPanel.instance then
        ExtractionPanel.instance:close()
        ExtractionPanel.instance = nil
    end
end


return ExtractionPanel
