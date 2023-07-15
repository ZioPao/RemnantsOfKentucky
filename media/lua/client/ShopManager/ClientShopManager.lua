require "ClientData"
require "BankManager/ClientBankManager"
require "SafehouseInstanceManager/ClientSafehouseInstanceHandler"

ClientShopManager = ClientShopManager or {}

--- Try buy an item for quantity
---@param item Table
---@param qunatity Number
ClientShopManager.TryBuy = function(item, quantity)
    local totalPrice = item.basePrice * item.multiplier * quantity

    if not ClientShopManager.CanBuy(totalPrice) then return end

    local data = {
        item = item,
        quantity = quantity,
        totalPrice = totalPrice
    }
    ClientBankManager.TryProcessTransaction(-totalPrice, "PZEFT-Shop", "BuyItems", data, "PZEFT-Shop", "BuyFailed",
        data)
end

--- Try sell items for quantity
--- See PZ_EFT_ShopItems_Config.addItem for item value
---@param sellData Table {{item = {}, quantity = 0}...}
ClientShopManager.TrySell = function(sellData)
    local hasData = false
    local data = {}
    data.items = {}
    data.totalPrice = 0

    for _, itemData in ipairs(sellData) do 
        if itemData and itemData.item and itemData.quantity then
            local totalPrice = itemData.item.basePrice * itemData.itm.multiplier * itemData.item.sellMultiplier * itemData.quantity
            data.totalPrice = data.totalPrice + totalPrice
            table.insert(data.items, itemData)
            hasData = true
        else
            print("ERROR: ClientShopManager.TrySell - Invalid sellData")
        end
    end

    if not hasData or not ClientShopManager.HasRequiredItems(data) then return end

    ClientBankManager.TryProcessTransaction(totalPrice, "PZEFT-Shop", "SellItems", data, "PZEFT-Shop", "SellFailed",
        data)
end

ClientShopManager.HasRequiredItems = function(data)
    -- TODO: Verify that player has item + quantity
    local player = getPlayer()
    local inventory = player:getInventory()

    return true
end


ClientShopManager.CanBuy = function(amount)
    local canBuy = false
    local player = getPlayer()
    local md = player:getModData()
    if not md.PZEFT then return false end

    local safehouse = ClientSafehouseInstanceHandler.getSafehouse()
    if not safehouse then return false end

    local storageBoxOffset = PZ_EFT_CONFIG.SafehouseInstanceSettings.storageRelativePosition
    local storageBoxLocation = {x = safehouse.x + storageBoxOffset.x, y = safehouse.y + storageBoxOffset.y, z = safehouse.z} 
    local storageBoxSq = getCell():getGridSquare(storageBoxLocation.x, storageBoxLocation.y, storageBoxLocation.z)
    if not storageBoxSq then return false end

    --TODO: Storage box validation

    local balance = md.PZEFT.accountBalance

    if balance >= amount then
        canBuy = true
    end

    return canBuy
end

