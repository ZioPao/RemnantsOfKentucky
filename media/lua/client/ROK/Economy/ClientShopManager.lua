require "ROK/ClientData"
local BankManager = require("ROK/Economy/ClientBankManager")
local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")
------------------

---@class ClientShopManager
local ClientShopManager = {}

--- Try buy an item for quantity
---@param item table
---@param quantity number?
function ClientShopManager.TryBuy(item, quantity)
    local totalPrice = item.basePrice * item.multiplier * quantity

    if not ClientShopManager.CanBuy(totalPrice) then
        debugPrint("WARN: ClientShopManager.CanBuy - Player tried to buy with insufficient balance")
        return false
    end

    local data = {
        item = item,
        quantity = quantity or 1,
        totalPrice = totalPrice
    }

    BankManager.TryProcessTransaction(-totalPrice, "PZEFT-Shop", "BuyItem", data, "PZEFT-Shop", "BuyFailed", data)
end

--- Try sell items for quantity
--- See PZ_EFT_ShopItems_Config.addItem for item value
---@param sellData {quantity : number, item : shopItemElement}
---@return boolean
function ClientShopManager.TrySell(sellData)


    -- TODO Simplify this, we don't need all of this to handle a simple sell

    local hasData = false
    local data = {}
    data.items = {}
    data.totalPrice = 0
    local totalPrice

    for _, itemData in ipairs(sellData) do
        if itemData and itemData.item and itemData.quantity then
            totalPrice = itemData.item.basePrice * itemData.item.multiplier * itemData.item.sellMultiplier *
                             itemData.quantity
            data.totalPrice = data.totalPrice + totalPrice
            table.insert(data.items, itemData)
            hasData = true
        else
            debugPrint("ERROR: ClientShopManager.TrySell - Invalid sellData")
            return false
        end
    end

    if not hasData or not ClientShopManager.CanSell(data.items) then
        return false
    end

    -- Remove items from the client

    -- Process transaction
    BankManager.TryProcessTransaction(totalPrice, EFT_MODULES.Shop, "SellItems", data, EFT_MODULES.Shop, "SellFailed", data)
    return true
end

---@param totalPrice number
---@return boolean
function ClientShopManager.CanBuy(totalPrice)
    local md = PZEFT_UTILS.GetPlayerModData()
    if md.bankAccount and type(md.bankAccount.balance) == 'number' then
        return md.bankAccount.balance >= totalPrice
    else
        debugPrint("ERROR: Account balance hasn't been initialized or something else is wrong")
    end

    return false
end

---@param items {quantity : number, item : shopItemElement}
---@return boolean
function ClientShopManager.CanSell(items)
    local player = getPlayer()
    local inventory = player:getInventory()

    for _, itemData in ipairs(items) do
        if inventory:getItemCountRecurse(itemData.item.fullType) < itemData.quantity then
            return false
        end
    end

    return true
end

---@return table
function ClientShopManager.GetDailyItems()
    local shopItems = ClientData.Shop.GetShopItems()
    if shopItems and shopItems.dailyInventory then
        return shopItems.dailyInventory
    end

    return {}
end

---@return table
function ClientShopManager.GetEssentialItems()
    local shopItems = ClientData.Shop.GetShopItems()
    if shopItems and shopItems.tags and shopItems.tags['ESSENTIALS'] then
        local essentialsList = {}
        for itemType, _ in pairs(shopItems.tags['ESSENTIALS']) do
            essentialsList[itemType] = nil
            essentialsList[itemType] = shopItems.items[itemType]
        end
        --PZEFT_UTILS.PrintTable(essentialsList)

        return essentialsList
    else
        return {}
    end
end
------------------------------------------------------------------------
--* COMMANDS FROM SERVER *--
------------------------------------------------------------------------

local ShopCommands = {}


---@param items any
function ShopCommands.GetShopItems(items)
    debugPrint("Receiving shop items")
    if items then
        local KEY_SHOP_ITEMS = "PZ-EFT-SHOP-ITEMS"
        ModData.add(KEY_SHOP_ITEMS, items)
    end

    -- TODO Handle daily items better
    local AdminShopManager = require("ROK/Economy/AdminShopManager")
    AdminShopManager.RefreshDailyItems()
end

---@param args {item : any, quantity : number}
function ShopCommands.BuyItem(args)
    debugPrint("BuyItem")

    if args == nil or args.item == nil or args.quantity == nil then
        debugPrint("ERROR: ServerCommands.BuyItem - Invalid buyData (args)")
        return
    end

    for i=1, args.quantity do
        SafehouseInstanceHandler.AddToCrate(args.item.fullType)
    end
end

---@param args table
function ShopCommands.SellItems(args)
    local player = getPlayer()
    local inventory = player:getInventory()

    for _, itemData in ipairs(args) do
        if itemData and itemData.item and itemData.quantity then
            for i = 1, itemData.quantity do
                inventory:Remove(itemData.item)
            end
        else
            debugPrint("ERROR: ServerCommands.SellItems - Invalid sellData")
            return
        end
    end
end

---@param args table
function ShopCommands.BuyFailed(args)
    --TODO: Maybe handle this on the UI somehow?
    debugPrint("Sell Failed!")
    PZEFT_UTILS.PrintTable(args, " - ")
end

---@param args table
function ShopCommands.SellFailed(args)
    --TODO: Maybe handle this on the UI somehow?
    debugPrint("Sell Failed!")
    PZEFT_UTILS.PrintTable(args, " - ")
end

------------------------------------

local function OnShopCommand(module, command, args)
    if module == EFT_MODULES.Shop and ShopCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        ShopCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnShopCommand)

return ClientShopManager