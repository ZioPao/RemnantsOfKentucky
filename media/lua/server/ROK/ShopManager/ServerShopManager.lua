if (not isServer()) and not (not isServer() and not isClient()) then
    return
end

require "ShopItems/PZ_EFT_ShopItems"
require "ROK/ServerData"
---------------------------

---@class ServerShopManager
ServerShopManager = ServerShopManager or {}

local function doTags(shopItems, id, item)
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

function ServerShopManager.loadShopPrices()
    local shopItems = ServerData.Shop.GetShopItems()
    shopItems.items = shopItems.items or {}
    shopItems.tags = shopItems.tags or {}
    shopItems.doInitShopItems = true --TODO: Remove, just for testing.
    if shopItems.doInitShopItems then
        shopItems.doInitShopItems = nil
        for i, v in pairs(PZ_EFT_ShopItems_Config.data) do
            shopItems = doTags(shopItems, i, v)
            shopItems.items[i] = {
                fullType = v.fullType,
                tags = v.tags,
                basePrice = v.basePrice,
                multiplier = v.initialMultiplier,       -- TODO this doesn't work for some reason
                sellMultiplier = v.sellMultiplier
            }

            --PZEFT_UTILS.PrintTable(shopItems.items[i])
        end
    end

    ServerData.Shop.TransmitShopItems()
end

Events.PZEFT_ServerModDataReady.Add(ServerShopManager.loadShopPrices)

function ServerShopManager.transmitShopItems()
    ServerData.Shop.TransmitShopItems()
end