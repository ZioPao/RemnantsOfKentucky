if not isServer() then return end
require "ShopItems/PZ_EFT_ShopItems"
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
    if item.tags["JUNK"] then
        shopItems.tags["JUNK"] = shopItems.tags["JUNK"] or {}
        shopItems.tags["JUNK"][id] = true
    end

    if item.tags["ESSENTIALS"] then
        shopItems.tags["ESSENTIALS"] = shopItems.tags["ESSENTIALS"] or {}
        shopItems.tags["ESSENTIALS"][id] = true
    end

    if item.tags["HIGHVALUE"] then
        shopItems.tags["HIGHVALUE"] = shopItems.tags["HIGHVALUE"] or {}
        shopItems.tags["HIGHVALUE"][id] = true
    end

    if item.tags["LOWVALUE"] then
        shopItems.tags["LOWVALUE"] = shopItems.tags["LOWVALUE"] or {}
        shopItems.tags["LOWVALUE"][id] = true
    end
    return shopItems
end


function ServerShopManager.LoadShopPrices()
    debugPrint("Loading Shop Prices")
    -- TODO Refactor this as a whole
    local shopItems = ServerData.Shop.GetShopItems()
    shopItems.items = shopItems.items or {}
    shopItems.tags = shopItems.tags or {}
    shopItems.doInitShopItems = true
    if shopItems.doInitShopItems then
        shopItems.doInitShopItems = nil
        for i, v in pairs(PZ_EFT_ShopItems_Config.data) do
            shopItems = DoTags(shopItems, i, v)
            shopItems.items[i] = {
                fullType = v.fullType,
                tags = v.tags,
                basePrice = v.basePrice,
                multiplier = v.initialMultiplier,
                sellMultiplier = v.sellMultiplier
            }
            --PZEFT_UTILS.PrintTable(shopItems.items[i])
        end
    end

    -- TODO This doesn't work, we should transmit it on a OnConnect
    --ServerData.Shop.TransmitShopItems()
end

function ServerShopManager.GetItems()
    local items = ServerData.Shop.GetShopItems()
    return items
end

Events.PZEFT_ServerModDataReady.Add(ServerShopManager.LoadShopPrices)

------------------------------------------------------------------------
--* COMMANDS FROM CLIENTS *--
------------------------------------------------------------------------

local ShopCommands = {}

--- Send data to clients
---@param playerObj IsoPlayer
function ShopCommands.TransmitShopItems(playerObj)
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