if not isServer() then return end
local ShopItemsManager = require("ROK/ShopItemsManager")
------------------------------

---@class ServerShopManager
local ServerShopManager = {}

---Transmit shop items
function ServerShopManager.TransmitShopItems()
    ServerData.Shop.TransmitShopItems()
end

---@param shopItems any
---@param id any
---@param item any
---@return table
local function DoTags(shopItems, id, item)
    local tags = {"FOOD", "CLOTHING_NORMAL", "CLOTHING_BAG", "CLOTHING_MILITARY", "TOOL", "TOOL_MELEE", "GUN",
    "GUN_PART","COSMETIC","EXP","DAILY", }
    for i=1, #tags do
        local tag = tags[i]
        if item.tags[tag] then
            shopItems.tags[tag] = shopItems.tags[tag] or {}
            shopItems.tags[tag][id] = true
        end
    end
    return shopItems
end


function ServerShopManager.LoadShopPrices()
    debugPrint("Loading Shop Prices")
    local shopItemsTemp = ServerData.Shop.GetShopItems()
    ShopItemsManager.GenerateDailyItems()
    shopItemsTemp.items = shopItemsTemp.items or {}
    shopItemsTemp.tags = shopItemsTemp.tags or {}
    shopItemsTemp.doInitShopItems = true
    if shopItemsTemp.doInitShopItems then
        shopItemsTemp.doInitShopItems = nil
        for i, v in pairs(ShopItemsManager.data) do
            shopItemsTemp = DoTags(shopItemsTemp, i, v)
            shopItemsTemp.items[i] = {
                fullType = v.fullType,
                tags = v.tags,
                basePrice = v.basePrice,
                multiplier = v.initialMultiplier,
                sellMultiplier = v.sellMultiplier
            }
            --PZEFT_UTILS.PrintTable(shopItems.items[i])
        end
    end
end


-- TODO This thing STINKS so fucking much. Rework this for the love of god
Events.EveryDays.Add(function()
    debugPrint("Regenerating daily items")
    ServerShopManager.LoadShopPrices()
    local items = ServerShopManager.GetItems()
    sendServerCommand(EFT_MODULES.Shop, "GetShopItems", items)
end)



Events.PZEFT_ServerModDataReady.Add(ServerShopManager.LoadShopPrices)


function ServerShopManager.GetItems()
    local items = ServerData.Shop.GetShopItems()
    return items
end


------------------------------------------------------------------------
--* COMMANDS FROM CLIENTS *--
------------------------------------------------------------------------

local ShopCommands = {}

--- Send shop data to a specific client
---@param playerObj IsoPlayer
function ShopCommands.TransmitShopItems(playerObj)
    debugPrint("Transmit Shop Items")
    local items = ServerShopManager.GetItems()
    sendServerCommand(playerObj, EFT_MODULES.Shop, "GetShopItems", items)
    --debugPrint(playerObj:getUsername() .. " asked for a retransmission of Shop Items")
    --ServerData.Shop.TransmitShopItems()
end

------------------------------------

function OnShopCommand(module, command, playerObj, args)
    if module == EFT_MODULES.Shop and ShopCommands[command] then
        debugPrint("Client Command - " .. EFT_MODULES.Shop .. "." .. command)
        ShopCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnShopCommand)



return ServerShopManager