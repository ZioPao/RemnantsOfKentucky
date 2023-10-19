--- Admin only functions
if not (not isClient() and not isServer()) and not isAdmin() then return end

require "ClientData"

AdminClientShopManager = AdminClientShopManager or {}

--- Transmit prices to server, which then will be transmitted back to clients
AdminClientShopManager.transmitShopItems = function()
    local shopItems = ClientData.Shop.GetShopItems()
    sendClientCommand('PZEFT-Shop', 'transmitShopItems', shopItems)
end

--- Adjust an item's price multiplier
---@param fullType String
---@param newMultiplier number decimal
---@return boolean
AdminClientShopManager.adjustItem = function(fullType, newMultiplier, sellMultiplier)
    local shopItems = ClientData.Shop.GetShopItems()
    shopItems.items = shopItems.items or {}
    
    if not shopItems.items[fullType] then 
        print("ERROR: AdminClientShopManager.adjustItem - Adjusted " .. fullType .. " doesn't exist!")
        return false 
    end

    shopItems.items[fullType].multiplier = newMultiplier or shopItems.items[fullType].multiplier
    shopItems.items[fullType].sellMultiplier = sellMultiplier or shopItems.items[fullType].sellMultiplier

    return true
end


--TODO Refresh daily items with % split between high value and low value
--- Manually refreshes the daily items
--- TODO: Refresh automatically on the server
AdminClientShopManager.refreshDailyItems = function()
    local shopItems = ClientData.Shop.GetShopItems()
    shopItems.dailyInventory = shopItems.dailyInventory or {}
    if not shopItems.items then 
        print("ERROR: AdminClientShopManager.refreshDailyItems - No shop items found!")
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

    sendClientCommand('PZEFT-Shop', 'transmitShopItems', shopItems)
end
