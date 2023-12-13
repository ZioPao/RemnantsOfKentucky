local StoreContainerPanel = require("ROK/UI/Store/Components/StoreContainerPanel")
local SellScrollItemsPanel = require("ROK/UI/Store/Sell/SellScrollItemsPanel")
local SellSidePanel = require("ROK/UI/Store/Sell/SellSidePanel")
----------------

---@class SellMainPanel : StoreContainerPanel
local SellMainPanel = StoreContainerPanel:derive("SellMainPanel")

---@param x any
---@param y any
---@param width any
---@param height any
---@return SellMainPanel
function SellMainPanel:new(x, y, width, height)
    local o = StoreContainerPanel:new(x, y, width, height, SellScrollItemsPanel, SellSidePanel)
    setmetatable(o, self)
    self.__index = self

    ---@cast o SellMainPanel
    SellMainPanel.instance = o
    return o
end

function SellMainPanel.SetSidePanelNotification(category)

    local sidePanel = SellMainPanel.instance.sidePanel
    ---@cast sidePanel SellSidePanel

    sidePanel:updateNotification(true, category)
end

Events.PZEFT_OnFailedSellTransfer.Add(SellMainPanel.SetSidePanelNotification)

-- TODO Add other events, like success

return SellMainPanel