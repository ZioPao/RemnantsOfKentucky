require "ClientData"
require "BankManager/ClientBankManager"

ClientShopManager = ClientShopManager or {}

--- Try buy an item for quantity
---@param item Table
---@param qunatity Number
ClientShopManager.TryBuy = function(item, quantity)
    -- TODO: Verify that player has item + quantity
    local totalPrice = item.basePrice * item.multiplier * quantity
    local data = {
        item = item,
        quantity = quantity,
        totalPrice = totalPrice
    }
    ClientBankManager.TryProcessTransaction(-totalPrice, "PZEFT-Shop", "BuyItems", data, "PZEFT-Shop", "BuyFailed",
        data, data)
end

--- Try sell items for quantity
---@param data Table {{item = {}, quantity = {}}...}
ClientShopManager.TrySell = function(data)
    -- TODO: Verify that player has item + quantity
    -- TOOD: Cater for multiple items
    local totalPrice = item.basePrice * item.multiplier * item.sellMultiplier * quantity
    local data = {
        item = item,
        quantity = quantity,
        totalPrice = totalPrice
    }
    ClientBankManager.TryProcessTransaction(totalPrice, "PZEFT-Shop", "SellItems", data, "PZEFT-Shop", "SellFailed",
        data, data)
end

ClientShopManager.HasRequiredItems = function(item, quantity)
    -- TODO: Verify that player has item + quantity
    return true
end


ClientShopManager.CanBuy = function()
    -- TODO: Verify that player has money + box next to safehouse door has capacity
    return true
end

