require "ClientData"
require "BankManager/ClientBankManager"

ClientShopManager = ClientShopManager or {}

--- Try buy an item for quantity
---@param item table
---@param quantity number
ClientShopManager.TryBuy = function(item, quantity)
    local totalPrice = item.basePrice * item.multiplier * quantity

    if not ClientShopManager.CanBuy(totalPrice) then
        print("WARN: ClientShopManager.CanBuy - Player tried to buy with insufficient balance")
        return false
    end

    local data = {
        item = item,
        quantity = quantity,
        totalPrice = totalPrice
    }

    ClientBankManager.TryProcessTransaction(-totalPrice, "PZEFT-Shop", "BuyItem", data, "PZEFT-Shop", "BuyFailed", data)
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
            totalPrice = itemData.item.basePrice * itemData.itm.multiplier * itemData.item.sellMultiplier *
                             itemData.quantity
            data.totalPrice = data.totalPrice + totalPrice
            table.insert(data.items, itemData)
            hasData = true
        else
            print("ERROR: ClientShopManager.TrySell - Invalid sellData")
            return;
        end
    end

    if not hasData or not ClientShopManager.CanSell(data.items) then
        return
    end

    ClientBankManager.TryProcessTransaction(totalPrice, "PZEFT-Shop", "SellItems", data, "PZEFT-Shop", "SellFailed",
        data)
end

ClientShopManager.CanBuy = function(totalPrice)
    local player = getPlayer()
    local md = player:getModData()
    if md and md.PZEFT and md.PZEFT.accountBalance then
        return md.PZEFT.accountBalance >= totalPrice
    end

    return false
end

ClientShopManager.CanSell = function(items)
    local player = getPlayer()
    local inventory = player:getInventory()

    for _, itemData in ipairs(items) do
        if inventory:getItemCountRecurse(itemData.item) < itemData.quantity then
            return false
        end
    end

    return true
end

ClientShopManager.GetEssentialItems = function()
    local shopItems = ClientData.Shop.GetShopItems()
    if shopItems and shopItems.dailyInventory then
        return shopItems.dailyInventory
    end

    return {}
end

ClientShopManager.GetDailyItems = function()
    local shopItems = ClientData.Shop.GetShopItems()
    if shopItems and shopItems.tags and shopItems.tags['ESSENTIALS'] then
        local dailyList = {}
        for itemType, _ in pairs(shopItems.tags['ESSENTIALS']) do
        dailyList[itemType] = nil
        dailyList[itemType] = shopItems.items[itemType]
        end
    else
        return {}
    end
end