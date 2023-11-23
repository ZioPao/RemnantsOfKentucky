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
        print("WARN: ClientShopManager.CanBuy - Player tried to buy with insufficient balance")
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
---@param sellData table {{item = {}, quantity = 0}...}
function ClientShopManager.TrySell(sellData)
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

    BankManager.TryProcessTransaction(totalPrice, EFT_MODULES.Shop, "SellItems", data, EFT_MODULES.Shop, "SellFailed", data)
end

---@param totalPrice number
---@return boolean
function ClientShopManager.CanBuy(totalPrice)
    local md = PZEFT_UTILS.GetPlayerModData()
    if md.bankAccount and type(md.bankAccount.balance) == 'number' then
        return md.bankAccount.balance >= totalPrice
    else
        print("ERROR: Account balance hasn't been initialized or something else is wrong")
    end

    return false
end

---@param items any
---@return boolean
function ClientShopManager.CanSell(items)
    local player = getPlayer()
    local inventory = player:getInventory()

    for _, itemData in ipairs(items) do
        if inventory:getItemCountRecurse(itemData.item) < itemData.quantity then
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

---@param args {item : any, quantity : number}
function ShopCommands.BuyItem(args)
    debugPrint("BuyItem")

    if args == nil or args.item == nil or args.quantity == nil then
        debugPrint("ERROR: ServerCommands.BuyItem - Invalid buyData (args)")
        return
    end

    local cratesTable = SafehouseInstanceHandler.GetCrates()
    -- Find the first crate which has available space
    -- TODO Do it

    local crateCounter = 1
    local inv = cratesTable[crateCounter]

    --getPlayer():getInventory():AddItems(args.item.fullType, args.quantity)
    for i=1, args.quantity do
        local item = InventoryItemFactory.CreateItem(args.item.fullType)

        if not inv:hasRoomFor(getPlayer(), item) then
            debugPrint("Switching to next crate")
            crateCounter = crateCounter + 1
            if crateCounter < #cratesTable then
                inv = cratesTable[crateCounter]
            else
                debugPrint("No more space in the crates, switching to dropping stuff in the player's inventory")
                inv = getPlayer():getInventory()
            end
        end
        inv:addItemOnServer(item)
        inv:addItem(item)
        inv:setDrawDirty(true)      -- TODO Not working, it doesn't show until next restart!
        ISInventoryPage.renderDirty = true
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