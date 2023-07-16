require "ClientData"
require "BankManager/ClientBankManager"

ClientShopManager = ClientShopManager or {}

--- Try buy an item for quantity
---@param item table
---@param quantity number
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
--- See PZ_EFT_ShopItems_Config.addItem for item value
---@param sellData table {{item = {}, quantity = 0}...}
ClientShopManager.TrySell = function(sellData)
    local hasData = false
    local data = {}
    data.items = {}
    data.totalPrice = 0
    local totalPrice

    for _, itemData in ipairs(sellData) do 
        if itemData and itemData.item and itemData.quantity then
            totalPrice = itemData.item.basePrice * itemData.itm.multiplier * itemData.item.sellMultiplier * itemData.quantity
            data.totalPrice = data.totalPrice + totalPrice
            table.insert(data.items, itemData)
            hasData = true
        else
            print("ERROR: ClientShopManager.TrySell - Invalid sellData")
        end
    end

    if not hasData or not ClientShopManager.HasRequiredItems(data) then return end

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

