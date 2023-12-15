require "ROK/ClientData"
local BankManager = require("ROK/Economy/ClientBankManager")
local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")
local ShopItemsManager = require("ROK/ShopItemsManager")
local ClientCommon = require("ROK/ClientCommon")
------------------

---@class ClientShopManager
local ClientShopManager = {}


function ClientShopManager.BuyInstaHeal()
    BankManager.TryProcessTransaction(-2500, EFT_MODULES.Shop, "BuyInstaHeal", {}, EFT_MODULES.Shop, "BuyFailed", {})
end


---@alias sellData table<integer, {itemData : shopItemElement, quantity : number, quality : number}>

--- ItemsList is coming from the ScrollingListBox, we need to keep track of quality stuff so that's why we need groups of every single item
---@param itemsList table<integer, {item : table<integer, InventoryItem>}>
---@return sellData
function ClientShopManager.StructureSellData(itemsList)
   -- Cycle through the items and structure them in the correct way
   local structuredData = {}
    for i=1, #itemsList do

        local quality = 1

        -- TODO Calculate quality based on Usages left, conditions, etc
        for j=1, #itemsList[i].item do
            local item = itemsList[i].item[j]
            quality = quality - 0
        end

        local genericItem = itemsList[i].item[1]
        local quantity = #itemsList[i].item
        local fullType = genericItem:getFullType()

        local itemData = ShopItemsManager.GetItem(fullType)
        table.insert(structuredData, {itemData = itemData, quantity = quantity, quality = quality})
    end

    return structuredData
end

--- Try buy an item for quantity. Let's assume that it's valid if we process the transaction
---@param itemData shopItemElement
---@param quantity number
---@param shopCat string
function ClientShopManager.TryBuy(itemData, quantity, shopCat)
    local totalPrice = itemData.basePrice * itemData.multiplier * quantity
    if not ClientShopManager.CanBuy(totalPrice) then
        debugPrint("WARN: ClientShopManager.CanBuy - Player tried to buy with insufficient balance")
        return
    end

    local data = {
        itemData = itemData,
        quantity = quantity or 1,
        totalPrice = totalPrice,
        shopCat = shopCat
    }

    BankManager.TryProcessTransaction(-totalPrice, EFT_MODULES.Shop, "BuyItem", data, EFT_MODULES.Shop, "BuyFailed", data)
end


---@alias transactionDataType table<integer, {fullType : string, quantity : string}>

--- Try sell items for quantity
--- See PZ_EFT_ShopItems_Config.addItem for item value
---@param sellData sellData
---@return boolean
function ClientShopManager.TrySell(sellData)

    if ClientShopManager.CanSell(sellData) == false then
        return false
    end

    ---@type transactionDataType
    local transactionData = {}
    local totalPrice = 0

    for k, data in pairs(sellData) do
        local pr = data.itemData.basePrice * data.itemData.sellMultiplier * data.quantity * data.quality
        totalPrice = totalPrice + pr

        table.insert(transactionData, {fullType = data.itemData.fullType, quantity = data.quantity})
    end

    BankManager.TryProcessTransaction(totalPrice, EFT_MODULES.Shop, "SellItems", transactionData, EFT_MODULES.Shop, "SellFailed", transactionData)
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

---@param items sellData
---@return boolean
function ClientShopManager.CanSell(items)
    local player = getPlayer()
    local inventory = player:getInventory()

    for _, itemData in ipairs(items) do
        if inventory:getItemCountRecurse(itemData.itemData.fullType) < itemData.quantity then
            return false
        end
    end

    return true
end

---@return table
function ClientShopManager.GetDailyItems()
    -- TODO Temp for playtest
    local shopItems = ClientData.Shop.GetShopItems()
    if shopItems and shopItems.tags and shopItems.tags['HIGHVALUE'] then
        local essentialsList = {}
        for itemType, _ in pairs(shopItems.tags['HIGHVALUE']) do
            essentialsList[itemType] = nil
            essentialsList[itemType] = shopItems.items[itemType]
        end
        --PZEFT_UTILS.PrintTable(essentialsList)

        return essentialsList
    else
        return {}
    end
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
    --PZEFT_UTILS.PrintTable(items)
    if items then
        local KEY_SHOP_ITEMS = "PZ-EFT-SHOP-ITEMS"
        ModData.add(KEY_SHOP_ITEMS, items)
    end
end


---@param args {itemData : shopItemElement, quantity : number, shopCat : string}
function ShopCommands.BuyItem(args)
    debugPrint("BuyItem")
    debugPrint(args.shopCat)

    if args == nil or args.itemData == nil or args.quantity == nil then
        debugPrint("ERROR: ServerCommands.BuyItem - Invalid buyData (args)")
        return
    end

    local usedCrates = {}

    for i=1, args.quantity do
        local crate = SafehouseInstanceHandler.AddToCrate(args.itemData.fullType)
        usedCrates[crate] = true
    end

    triggerEvent("PZEFT_OnSuccessfulBuy", args.shopCat, usedCrates)
end


function ShopCommands.BuyInstaHeal()
    ClientCommon.InstaHeal()
end


---@param transactionData transactionDataType
function ShopCommands.SellItems(transactionData)
    debugPrint("SellItemsSuccess")

    local pl = getPlayer()
    local plInv = pl:getInventory()

    for i=1, #transactionData do
        local data = transactionData[i]
        for _=1, data.quantity do
            local item = plInv:FindAndReturn(data.fullType)
            ISRemoveItemTool.removeItem(item, pl)
        end
    end
    triggerEvent("PZEFT_OnSuccessfulSell", "successful")
end


---@param args table
function ShopCommands.BuyFailed(args)
    debugPrint("Sell Failed!")
    PZEFT_UTILS.PrintTable(args, " - ")
end

---@param args table
function ShopCommands.SellFailed(args)
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