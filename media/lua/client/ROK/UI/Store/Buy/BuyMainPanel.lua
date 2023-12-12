local BuyScrollItemsPanel = require("ROK/UI/Store/Buy/BuyScrollItemsPanel")
local BuySidePanel = require("ROK/UI/Store/Buy/BuySidePanel")
local StoreContainerPanel = require("ROK/UI/Store/Components/StoreContainerPanel")
----------------

---@class BuyMainPanel : StoreContainerPanel
---@field itemsTable table<string, {actualItem : Item, fullType : string}>
---@field shopCat string
local BuyMainPanel = StoreContainerPanel:derive("BuyMainPanel")

BuyMainPanel.instances = {}

---@param x any
---@param y any
---@param width any
---@param height any
---@param itemsTable table<string, {actualItem : Item, fullType : string}>
---@param shopCat string
---@return BuyMainPanel
function BuyMainPanel:new(x, y, width, height, itemsTable, shopCat)
    local o = StoreContainerPanel:new(x, y, width, height, BuyScrollItemsPanel, BuySidePanel)
    setmetatable(o, self)
    self.__index = self

    o.itemsTable = itemsTable
    o.shopCat = shopCat

    ---@cast o BuyMainPanel
    BuyMainPanel.instances[shopCat] = o
    return o
end

function BuyMainPanel:createChildren()
    StoreContainerPanel.createChildren(self)
    self.scrollPanel:initialiseList(self.itemsTable)

end

function BuyMainPanel.SetSuccessfulBuyConfirmation(category)
    debugPrint("SetSuccessfulBuyConfirmation")

    local t = BuyMainPanel.instances

    ---@type BuySidePanel
    local sidePanel = BuyMainPanel.instances[category].sidePanel

    sidePanel.showBuyConfirmation = true
    sidePanel.timeShowBuyConfirmation = os.time() + 3
end
Events.PZEFT_OnSuccessfulBuy.Add(BuyMainPanel.SetSuccessfulBuyConfirmation)

return BuyMainPanel