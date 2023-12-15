local BuyScrollItemsPanel = require("ROK/UI/Store/Buy/BuyScrollItemsPanel")
local BuySidePanel = require("ROK/UI/Store/Buy/BuySidePanel")
local StoreContainerPanel = require("ROK/UI/Store/Components/StoreContainerPanel")
----------------

---@class BuyMainPanel : StoreContainerPanel
---@field itemsTable table<string, {actualItem : Item, fullType : string}>
---@field usedCrates table<IsoObject, boolean>?
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

function BuyMainPanel:render()
    StoreContainerPanel.render(self)

    if self.usedCrates == nil then return end

    -- TODO Add timer to this
    for obj, _ in pairs(self.usedCrates) do
        ---@cast obj IsoObject
        obj:setHighlighted(true, false)
        local OBJECT_HIGHLIGHT_COLOR = ColorInfo.new(0,1,0,1)
        obj:setHighlightColor(OBJECT_HIGHLIGHT_COLOR)
        obj:setBlink(true)
        obj:setOutlineHighlight(true)
        obj:setOutlineHlBlink(true)
        obj:setOutlineHighlightCol(1.0, 1.0, 1.0, 1.0)
    end
end

---comment
---@param category string
---@param usedCrates table<IsoObject,boolean>
function BuyMainPanel.SetSuccessfulBuyConfirmation(category, usedCrates)
    debugPrint("SetSuccessfulBuyConfirmation")

    local t = BuyMainPanel.instances

    ---@type BuySidePanel
    local sidePanel = BuyMainPanel.instances[category].sidePanel

    sidePanel.showBuyConfirmation = true
    sidePanel.timeShowBuyConfirmation = os.time() + 3


    -- Render highlighted containers
    BuyMainPanel.instances[category].usedCrates = usedCrates
end
Events.PZEFT_OnSuccessfulBuy.Add(BuyMainPanel.SetSuccessfulBuyConfirmation)

return BuyMainPanel