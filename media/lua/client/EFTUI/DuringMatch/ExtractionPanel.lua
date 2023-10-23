local ConfirmationPanel = require("EFTUI/ConfirmationPanel")


local ExtractionPanel = ConfirmationPanel:derive("ExtractionPanel")

---Starts a new Extraction panel
---@param x number
---@param y number
---@param width number
---@param height number
---@return ISPanel
function ExtractionPanel:new(x, y, width, height)
    local alertText = "Are you gonna extract?"

    local o = ConfirmationPanel:new(x, y, width, height, alertText, nil, EFT_ExtractionHandler.DoExtraction)
    setmetatable(o, self)
    self.__index = self
    o:initialise()
    ExtractionPanel.instance = o
    return o
end


function ExtractionPanel.Open()
    local width = 100
    local height = 100
    local padding = 50
    local posX = getCore():getScreenWidth() / 2
    local posY = getCore():getScreenHeight() - height - padding

    -- TODO Position should be somewhere in the bottom
    local panel = ExtractionPanel:new(width, height, posX, posY)
    panel:initialise()
    panel:addToUIManager()
    panel:bringToTop()
end

function ExtractionPanel.Close()
    ExtractionPanel.instance:close()
end

return ExtractionPanel