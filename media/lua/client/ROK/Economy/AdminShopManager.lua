
require "ROK/ClientData"
-----------------------

---@class AdminShopManager
local AdminShopManager = {}

--- Transmit prices to server, which then will be transmitted back to clients
function AdminShopManager.TransmitShopItems()
    local shopItems = ClientData.Shop.GetShopItems()
    --sendClientCommand(EFT_MODULES.Shop, 'TransmitShopItems', shopItems)
end

--- Adjust an item's price multiplier
---@param fullType String
---@param newMultiplier number decimal
---@return boolean
function AdminShopManager.AdjustItem(fullType, newMultiplier, sellMultiplier)
    local shopItems = ClientData.Shop.GetShopItems()
    shopItems.items = shopItems.items or {}

    if not shopItems.items[fullType] then
        debugPrint("ERROR: AdminClientShopManager.AdjustItem - Adjusted " .. fullType .. " doesn't exist!")
        return false
    end

    shopItems.items[fullType].multiplier = newMultiplier or shopItems.items[fullType].multiplier
    shopItems.items[fullType].sellMultiplier = sellMultiplier or shopItems.items[fullType].sellMultiplier

    return true
end

--TODO Refresh daily items with % split between high value and low value
--- Manually refreshes the daily items
function AdminShopManager.RefreshDailyItems()
    debugPrint("Refreshing daily items")
    -- TODO THIS IS JUST HERE AS A WORKAROUND! This stuff should run automatically on the server and not get triggered here
    --ServerData_client_debug.loadShopPrices()

    local shopItems = ClientData.Shop.GetShopItems()
    shopItems.dailyInventory = shopItems.dailyInventory or {}
    if not shopItems.items then
        debugPrint("ERROR: AdminClientShopManager.RefreshDailyItems - No shop items found!")
        return
    end

    --TODO: Get daily inventory count?
    --TODO: Sandbox options
    --TODO: Fix pick random pairs
    local split = 0.5
    local count = 10

    local highValueItemsCount = math.floor(count * split)
    local lowValueItemsCount = count - highValueItemsCount

    local highValueItems = shopItems.tags["HIGHVALUE"]
    local lowValueItems = shopItems.tags["LOWVALUE"]

    shopItems.dailyInventory = {}

    if highValueItems then
        local highValueTableFullTypes = PZEFT_UTILS.PickRandomPairsWithoutRepetitions(highValueItems, highValueItemsCount)

        for id,_ in pairs(highValueTableFullTypes) do
            shopItems.dailyInventory[id] = shopItems.items[id]
        end
    end

    if lowValueItems then
        local lowValueTableFullTypes = PZEFT_UTILS.PickRandomPairsWithoutRepetitions(lowValueItems, lowValueItemsCount)

        for id,_ in pairs(lowValueTableFullTypes) do
            shopItems.dailyInventory[id] = shopItems.items[id]
        end
    end

    --sendClientCommand(EFT_MODULES.Shop, 'TransmitShopItems', shopItems)
end

-------------------------------------------------------------------

-- TODO This is just a workaround for the proof of concept build
--Events.OnCreatePlayer.Add(AdminShopManager.RefreshDailyItems)


return AdminShopManager