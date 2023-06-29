--- Admin only functions

if not isAdmin() then return end

require "ClientData"

AdminClientShopManager = AdminClientShopManager or {}

--- Transmit prices to server, which then will be transmitted back to clients
AdminClientShopManager.transmitPrices = function()
    local shopItems = ClientData.Shop.GetShopItems()
    sendClientCommand('PZEFT-Shop', 'transmitPrices', shopItems)
end

--- Adjust an item's price multiplier
---@param fullType String
---@param newMultiplier decimal
AdminClientShopManager.adjustItem = function(fullType, newMultiplier, sellMultiplier)
    local shopItems = ClientData.Shop.GetShopItems()
    shopItems[fullType].multiplier = newMultiplier or shopItems[fullType].multiplier
    shopItems[fullType].sellMultiplier = sellMultiplier or shopItems[fullType].sellMultiplier
end