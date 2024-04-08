require "ROK/ClientData"
local BankManager = require("ROK/Economy/ClientBankManager")
local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")
local ClientCommon = require("ROK/ClientCommon")
local ShopItemsManager = require("ROK/ShopItemsManager")


------------------

---@class ClientShopManager
local ClientShopManager = {}

---@param sellItemsData sellItemsDataType
function ClientShopManager.GetSellableItemsInInventory(sellItemsData)
    ---@param item InventoryItem
    ---@param plObj any
    local function predicateFindItemWithId(item, plObj)
        for fullType, dataTable in pairs(sellItemsData) do
            if item:getFullType() == fullType then
                for j = 1, #dataTable do
                    local data = dataTable[j]
                    if item:getID() == data.id then
                        return true
                    end
                end
            end
        end
        return false
    end

    local pl = getPlayer()
    local plInv = pl:getInventory()

    ---@diagnostic disable-next-line: param-type-mismatch
    local t = plInv:getAllEvalRecurse(predicateFindItemWithId)
    -- debugPrint("___________________________________")
    -- debugPrint(t)

    return t
end

---------------------------------
--* Instaheal section

function ClientShopManager.AskToBuyInstaHeal()
    local text = getText("IGUI_Shop_InstaHeal_Confirmation")
    local ConfirmationPanel = require("ROK/UI/ConfirmationPanel")

    -- UGLY Jank, 500 is the width but it's handled inside ConfirmationPanel.
    local x = (getCore():getScreenWidth() - 500) / 2
    local y = getCore():getScreenHeight() / 2

    ConfirmationPanel.Open(text, x, y, nil, ClientShopManager.BuyInstaHeal)
end

function ClientShopManager.BuyInstaHeal()
    BankManager.TryProcessTransaction(-2500, EFT_MODULES.Shop, "BuyInstaHeal", {}, EFT_MODULES.Shop, "BuyFailed", {})
end

-------------------------------


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
---@param sellData sellItemsDataType
---@return boolean
function ClientShopManager.TrySell(sellData)
    local ShopItemsManager = require("ROK/ShopItemsManager")
    if not ClientShopManager.CanSell(sellData) then return false end

    local totalPrice = 0
    for fullType, data in pairs(sellData) do
        local eftShopData = ShopItemsManager.GetItem(fullType)

        for i = 1, #data do
            local itemData = data[i]
            totalPrice = totalPrice + (eftShopData.basePrice * eftShopData.sellMultiplier * itemData.quality)
        end
    end

    BankManager.TryProcessTransaction(totalPrice, EFT_MODULES.Shop, "SellItems", sellData, EFT_MODULES.Shop,
        "SellFailed", {})
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

---@param items sellItemsDataType
---@return boolean
function ClientShopManager.CanSell(items)
    local inv = getPlayer():getInventory()

    for fullType, itemData in pairs(items) do
        if inv:getItemCountRecurse(fullType) < #itemData then
            return false
        end
    end

    return true
end

---@param tag string
---@return table
function ClientShopManager.GetItemsWithTag(tag)
    local shopItemsData = ShopItemsManager.GetShopItemsData()
    if shopItemsData and shopItemsData.tags and shopItemsData.tags[tag] then
        local itemsList = {}
        for itemType, _ in pairs(shopItemsData.tags[tag]) do
            -- Check if tag is active
            if shopItemsData.items[itemType].tag == tag then
                itemsList[itemType] = nil
                itemsList[itemType] = shopItemsData.items[itemType]
            end
        end

        return itemsList
    else
        return {}
    end
end

---@return table
function ClientShopManager.GetDailyItems()
    local shopItemsData = ShopItemsManager.GetShopItemsData()
    return shopItemsData.daily
end

------------------------------------------------------------------------
--* COMMANDS FROM SERVER *--
------------------------------------------------------------------------

local ShopCommands = {}

---@param items any
function ShopCommands.ReceiveShopItems(items)
    debugPrint("Receiving shop items")
    --PZEFT_UTILS.PrintTable(items)
    if items then
        ModData.add(EFT_ModDataKeys.SHOP_ITEMS, items)
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


    -- Check if is moveable. if it is, send to specific point

    local isRefund = false
    local item = InventoryItemFactory.CreateItem(args.itemData.fullType)
    local objectsToHighligt = {}

    if instanceof(item, "Moveable") and item:getSpriteGrid() == nil then
        ---@cast item Moveable

        -- TODO Refund stuff?
        local floorObj = SafehouseInstanceHandler.TryToPlaceMoveable(item)
        if floorObj then
            objectsToHighligt[floorObj] = true
        end
    else
        for i = 1, args.quantity do
            local crate = SafehouseInstanceHandler.TryToAddToCrate(args.itemData.fullType)
            if crate then
                objectsToHighligt[crate] = true
            else
                -- if no crates were available, a refund will be given to the player
                isRefund = true
                sendClientCommand(EFT_MODULES.Bank, "ProcessTransaction", { amount = args.itemData.basePrice })
            end
        end
    end

    triggerEvent("PZEFT_OnSuccessfulBuy", args.shopCat, objectsToHighligt, isRefund)
end

function ShopCommands.BuyInstaHeal()
    ClientCommon.InstaHeal()
end

---@param sellItemsData sellItemsDataType
function ShopCommands.SellItems(sellItemsData)
    local itemsInInventoryArray = ClientShopManager.GetSellableItemsInInventory(sellItemsData)
    local pl = getPlayer()
    for i = 0, itemsInInventoryArray:size() - 1 do
        local item = itemsInInventoryArray:get(i)
        ISRemoveItemTool.removeItem(item, pl)
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
