local GenericUI = require("ROK/UI/GenericUI")
local CommonStore = require("ROK/UI/Store/Components/CommonStore")
------------------------


---@class RightSidePanel : ISPanel
---@field mainPanel ISPanel
local RightSidePanel = ISPanel:derive("RightSidePanel")

---Starts a new quantity panel
---@param x number
---@param y number
---@param width number
---@param height number
---@param mainPanel StoreScrollingListBox
---@return RightSidePanel
function RightSidePanel:new(x, y, width, height, mainPanel)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o:initialise()
    o.mainPanel = mainPanel
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.7 }


    RightSidePanel.instance = o

    ---@cast o RightSidePanel
    return o
end

function RightSidePanel:createChildren()
    ISPanel.createChildren(self)

    GenericUI.CreateISRichTextPanel(self, "textPanel", 0, 0, self.width, self.height)

    local xMargin = CommonStore.MARGIN_X
    local elementX = xMargin
    local elementY = self:getBottom() - CommonStore.BIG_BTN_HEIGHT -  CommonStore.MARGIN_Y
    local elementWidth = self.width - xMargin * 2
    local elementHeight = CommonStore.BIG_BTN_HEIGHT

    self.bottomBtn = ISButton:new(elementX, elementY, elementWidth, elementHeight, "", self, self.onClick)
    self.bottomBtn:setEnable(false)
    self:addChild(self.bottomBtn)
end


function RightSidePanel:render()
    ISPanel.render(self)
end

function RightSidePanel:close()
    if self.confirmationPanel then
        self.confirmationPanel:close()
    end

    ISPanel.close(self)
end

return RightSidePanel
