local CommonStore = require("ROK/UI/Store/Components/CommonStore")
------------------------


---@class RightSidePanel : ISPanel
---@field mainPanel StoreScrollingListBox
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

    self.textPanel = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.textPanel:initialise()
    self:addChild(self.textPanel)
    self.textPanel.defaultFont = UIFont.Medium
    self.textPanel.anchorTop = true
    self.textPanel.anchorLeft = false
    self.textPanel.anchorBottom = true
    self.textPanel.anchorRight = false
    self.textPanel.marginLeft = 0
    self.textPanel.marginTop = 10
    self.textPanel.marginRight = 0
    self.textPanel.marginBottom = 0
    self.textPanel.autosetheight = false
    self.textPanel.background = false
    self.textPanel:setText("")
    self.textPanel:paginate()


    local xMargin = CommonStore.MARGIN_X
    local elementX = xMargin
    local elementY = self:getBottom() - CommonStore.BIG_BTN_HEIGHT -  CommonStore.MARGIN_Y
    local elementWidth = self.width - xMargin * 2
    local elementHeight = CommonStore.BIG_BTN_HEIGHT

    self.bottomBtn = ISButton:new(elementX, elementY, elementWidth, elementHeight, "", self, self.onClick)
    self.bottomBtn:setEnable(false)
    self:addChild(self.bottomBtn)
end

function RightSidePanel:getCostForSelectedItem()
    local selectedItem = self.mainPanel:getSelectedItem()
    if selectedItem == nil then return end
    local itemCost = selectedItem.basePrice

    local finalCost = tonumber(self.entryAmount:getInternalText()) * itemCost
    return finalCost
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
