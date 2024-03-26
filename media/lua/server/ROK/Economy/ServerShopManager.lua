if not isServer() then return end
------------------------------
local ShopItemsManager = require("ROK/ShopItemsManager")

---@class ServerShopManager
local ServerShopManager = {}

function ServerShopManager.GetItems()
    local items = ServerData.Shop.GetShopItemsData()
    return items
end

---@param shopItems shopItemsTable
---@param id integer
---@param item shopItemElement
---@return shopItemsTable
local function DoTags(shopItems, id, item)

    local tags = PZ_EFT_CONFIG.Shop.tags

    for i=1, #tags do
        local tag = tags[i]

        if item.tag == tag then
            shopItems.tags[tag] = shopItems.tags[tag] or {}
            shopItems.tags[tag][id] = true
        end

    end
    return shopItems
end

function ServerShopManager.LoadShopPrices()

    -- Readd items from JSON
    ShopItemsManager.LoadData()

    local shopItemsData = ServerData.Shop.GetShopItemsData()

    -- Init
    shopItemsData.items = {}
    shopItemsData.tags = {}

    for i, v in pairs(ShopItemsManager.data) do
        shopItemsData = DoTags(shopItemsData, i, v)
        shopItemsData.items[i] = ShopItemsManager.GetItem(v.fullType)
    end


    --!!!!!!!!!!!!!!
    -- Generating daily items depends on having the tags already done.
    -- After this, we need to re-set the tags table once again to make them available
    --!!!!!!!!!!!!!!!
    ShopItemsManager.GenerateDailyItems()

    -- UGLY Awful, but it'll do for now
    shopItemsData = ServerData.Shop.GetShopItemsData()
    for i,v in pairs(ShopItemsManager.data) do
        shopItemsData = DoTags(shopItemsData, i, v)
    end

end

Events.PZEFT_ServerModDataReady.Add(ServerShopManager.LoadShopPrices)


function ServerShopManager.RetransmitItems()
    debugPrint("Regenerating daily items")
    ServerShopManager.LoadShopPrices()
    local items = ServerShopManager.GetItems()
    sendServerCommand(EFT_MODULES.Shop, "GetShopItems", items)
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

    local items = ServerShopManager.GetItems()
    sendServerCommand(playerObj, EFT_MODULES.Shop, "ReceiveShopItems", items)
    --debugPrint(playerObj:getUsername() .. " asked for a retransmission of Shop Items")
    --ServerData.Shop.TransmitShopItems()
end

---@param playerObj IsoPlayer
---@param args {items: table<integer, {fullType : string, tag : string, basePrice : number}>}
function ShopCommands.OverrideShopItems(playerObj, args)
    ShopItemsManager.OverwriteData(args.items)
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