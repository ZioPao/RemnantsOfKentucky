if not isServer() then return end

local json = require("ROK/JSON")
local ShopItemsManager = require("ROK/ShopItemsManager")

------------------------------

---@class ServerShopManager
local ServerShopManager = {}


--* LOADING AND INIT DATA *--

---@private
local function GetKeys(t)
    local t2 = {}
    --PZEFT_UTILS.PrintTable(t)

    for key, _ in pairs(t) do
        table.insert(t2, key)
    end

    return t2
end

---@private
---@param percentage number
---@param items shopItemsTable
---@param tag string
local function FetchNRandomItems(percentage, items, tag)
    local amount = math.floor(PZ_EFT_CONFIG.Shop.dailyItemsAmount * (percentage / 100))

    debugPrint("Adding " .. tostring(amount) .. " for " .. tag)
    local currentAmount = 0

    -- We want to pop stuff from here
    local keys = GetKeys(items.tags[tag])
    --PZEFT_UTILS.PrintTable(keys)

    while currentAmount < amount do
        local randIndex = ZombRand(#keys) + 1
        local fType = keys[randIndex]
        debugPrint("Adding to daily: fType=" .. fType)

        -- Check if Item actually exists and it's not in the blacklist
        local item = InventoryItemFactory.CreateItem(fType)
        if item and not PZ_EFT_CONFIG.Shop.blacklist[fType] then
            ShopItemsManager.AddToDaily(fType)
            currentAmount = currentAmount + 1
        end
        table.remove(keys, randIndex)
    end
end

---@private
function ServerShopManager.GenerateDailyItems()
    debugPrint("Generating daily items")

    ShopItemsManager.ResetDaily()

    local items = ShopItemsManager.GetShopItemsData()

    -- Should stack to 100%
    FetchNRandomItems(20, items, 'WEAPON')
    FetchNRandomItems(10, items, 'TOOL')
    FetchNRandomItems(15, items, "MILITARY_CLOTHING")
    FetchNRandomItems(10, items, "CLOTHING")
    FetchNRandomItems(5, items, "SKILL_BOOK")
    FetchNRandomItems(10, items, "FURNITURE")
    FetchNRandomItems(5, items, "FIRST_AID")
    FetchNRandomItems(5, items, "FOOD")
    FetchNRandomItems(20, items, "VARIOUS")
end

---@private
---@return table<integer, {fullType : string, tag : string, basePrice : integer}>
function ServerShopManager.LoadDataFromJson()

    -- TODO Force load from admin panel

    -- Load default JSON, if there's no custom one in the cachedir
    local fileName = PZ_EFT_CONFIG.Shop.jsonName
    local readData = json.readFile(fileName)

    -- Check if is blank or not
    if not readData then
        debugPrint("Loading default prices")
        local writer = getFileWriter(fileName, true, false)
        local itemsStr = json.readModFile('ROK', 'media/data/default_prices.json')
        writer:write(itemsStr)
        writer:close()

        -- get data again
        readData = json.readFile(fileName)
    end

    local parsedData = json.parse(readData)
    --PZEFT_UTILS.PrintTable(parsedData)
    return parsedData
end

---@private
---@param itemsData table<integer, {fullType : string, tag : string, basePrice : number}>
function ServerShopManager.OverwriteJsonData(itemsData)
    local stringifiedData = json.stringify(itemsData)
    local writer = getFileWriter(PZ_EFT_CONFIG.Shop.jsonName, true, false)
    writer:write(stringifiedData)
    writer:close()
end

function ServerShopManager.LoadShopPrices()
    local parsedData = ServerShopManager.LoadDataFromJson()

    -- Load items from JSON into ModData
    for i = 1, #parsedData do
        local d = parsedData[i]
        debugPrint("Adding from JSON => " .. d.fullType)
        ShopItemsManager.AddItem(d.fullType, d.tag, d.basePrice)
    end


    --Check other items
    local allItems = getScriptManager():getAllItems()
    for i = 0, allItems:size() - 1 do
        ---@type Item
        local item = allItems:get(i)
        local fullType = item:getModuleName() .. "." .. item:getName()

        --debugPrint(fullType)
        if not ShopItemsManager.GetItem(fullType) then
            if not item:isHidden() then
                debugPrint("No data from JSON => " .. fullType)
                ShopItemsManager.AddItem(fullType, "VARIOUS", 100)
            else
                debugPrint("Item is hidden, do not consider it => " .. fullType)
            end
            -- else
            --     debugPrint("Item already set from JSON => " .. fullType)
        end
    end

    ServerShopManager.GenerateDailyItems()
    ModData.transmit(EFT_ModDataKeys.SHOP_ITEMS)
end

Events.PZEFT_ServerModDataReady.Add(ServerShopManager.LoadShopPrices)


function ServerShopManager.RetransmitItems()
    debugPrint("Regeneraint daily items and retransmitting")
    ServerShopManager.GenerateDailyItems()
    ModData.transmit(EFT_ModDataKeys.SHOP_ITEMS)
    --ServerShopManager.LoadShopPrices()
    --ModData.transmit(EFT_ModDataKeys.SHOP_ITEMS)
end

Events.PZEFT_OnMatchEnd.Add(ServerShopManager.RetransmitItems)

------------------------------------------------------------------------
--* COMMANDS FROM CLIENTS *--
------------------------------------------------------------------------

local ShopCommands = {}
local MODULE = EFT_MODULES.Shop

--- Send shop data to a specific client
---@param playerObj IsoPlayer
function ShopCommands.TransmitShopItems(playerObj)
    debugPrint("Transmitting Shop Items to Client => " .. playerObj:getUsername())

    local items = ShopItemsManager.GetShopItemsData()
    sendServerCommand(playerObj, EFT_MODULES.Shop, "ReceiveShopItems", items)
end

---@param playerObj IsoPlayer
---@param args {items: table<integer, {fullType : string, tag : string, basePrice : number}>}
function ShopCommands.OverrideShopItems(playerObj, args)
    ServerShopManager.OverwriteJsonData(args.items)
    ServerShopManager.RetransmitItems()
end

------------------------------------

local function OnShopCommand(module, command, playerObj, args)
    --debugPrint("Received something")
    --debugPrint(module)
    --debugPrint(command)
    if module == MODULE and ShopCommands[command] then
        debugPrint("Client Command - " .. EFT_MODULES.Shop .. "." .. command)
        ShopCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnShopCommand)



return ServerShopManager
