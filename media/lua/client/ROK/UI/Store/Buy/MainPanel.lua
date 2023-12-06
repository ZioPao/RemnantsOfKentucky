local BuyScrollItemsPanel = require("ROK/UI/Store/Buy/ScrollItemsPanel")
local ClientShopManager = require("ROK/Economy/ClientShopManager")
local BuySidePanel = require("ROK/UI/Store/Buy/RightSidePanel")
local StoreContainerPanel = require("ROK/UI/Store/Components/StoreContainerPanel")
----------------

---@class BuyMainPanel : StoreContainerPanel
local BuyMainPanel = StoreContainerPanel:derive("BuyMainPanel")

---comment
---@param x any
---@param y any
---@param width any
---@param height any
---@param itemsTable {}
---@return BuyMainPanel
function BuyMainPanel:new(x, y, width, height, itemsTable)
    local o = StoreContainerPanel:new(x, y, width, height, BuyScrollItemsPanel, BuySidePanel)
    setmetatable(o, self)
    self.__index = self

    self.itemsTable = itemsTable

    ---@cast o BuyMainPanel
    BuyMainPanel.instance = o
    return o
end

function BuyMainPanel:createChildren()
    StoreContainerPanel.createChildren(self)
    self.scrollPanel:initialiseList(self.itemsTable)
end

return BuyMainPanel