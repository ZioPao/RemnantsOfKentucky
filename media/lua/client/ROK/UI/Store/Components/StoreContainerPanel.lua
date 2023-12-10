local GenericUI = require("ROK/UI/GenericUI")
local ConfirmationPanel = require("ROK/UI/ConfirmationPanel")
----------------

---@class StoreContainerPanel : ISPanelJoypad
---@field scrollPanel BaseScrollItemsPanel
---@field sidePanel RightSidePanel
---@field parent MainShopPanel
local StoreContainerPanel = ISPanelJoypad:derive("StoreContainerPanel")

---@param x any
---@param y any
---@param width any
---@param height any
---@param scrollModal BaseScrollItemsPanel
---@param sideModal RightSidePanel
---@return ISPanelJoypad
function StoreContainerPanel:new(x, y, width, height, scrollModal, sideModal)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    self.scrollModal = scrollModal
    self.sideModal = sideModal

    StoreContainerPanel.instance = o
    return o
end

function StoreContainerPanel:initialise()
    ISPanelJoypad.initialise(self)

    --self.scrollPanel:initialiseList(ClientShopManager.GetEssentialItems())
end

function StoreContainerPanel:createChildren()
    local paneWidth = self.width / 2 - 20
    local paneY = GenericUI.SMALL_FONT_HGT + 2 * 2
    local paneHeight = self.height - paneY - 10

    local scrollX = 10

    self.scrollPanel = self.scrollModal:new(scrollX, paneY, paneWidth, paneHeight)
    self.scrollPanel:initialise()
    self.scrollPanel:setAnchorRight(true)
    self.scrollPanel:setAnchorBottom(true)
    self:addChild(self.scrollPanel)

    local sideX = self.width - paneWidth - 10

    self.sidePanel = self.sideModal:new(sideX, paneY, paneWidth, paneHeight)
    self.sidePanel:initialise()
    self:addChild(self.sidePanel)

end

function StoreContainerPanel:render()
    ISPanelJoypad.render(self)

    if self.confirmationPanel then
        local confX = self.parent:getAbsoluteX() + (self.parent:getWidth()/2)
        local confY = self.parent:getAbsoluteY() + self.parent:getHeight() + 20
        self.confirmationPanel:setX(confX)
        self.confirmationPanel:setY(confY)
    end
end

---@param text string
function StoreContainerPanel:openConfirmationPanel(text, onConfirm)
    local confX = self.parent:getAbsoluteX() + (self.parent:getWidth()/2)
    local confY = self.parent:getAbsoluteY() + self.parent:getHeight() + 20
    self.confirmationPanel = ConfirmationPanel.Open(text, confX, confY, self, onConfirm)
end

function StoreContainerPanel:close()
    StoreContainerPanel.close(self)
end

return StoreContainerPanel