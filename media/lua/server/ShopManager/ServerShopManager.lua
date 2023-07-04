if (not isServer()) and not (not isServer() and not isClient()) then return end

require "ShopItems/PZ_EFT_ShopItems"
require "ServerData"

ServerShopManager = ServerShopManager or {}

local function doTags(shopItems, id, item)
    if v.tags["JUNK"] then
        shopItems.tags["JUNK"] = shopItems.tags["JUNK"] or {}
        shopItems.tags["JUNK"][i] = true 
    end

    if v.tags["ESSENTIALS"] then
        shopItems.tags["ESSENTIALS"] = shopItems.tags["ESSENTIALS"] or {}
        shopItems.tags["ESSENTIALS"][i] = true 
    end

    if v.tags["HIGHVALUE"] then
        shopItems.tags["HIGHVALUE"] = shopItems.tags["HIGHVALUE"] or {}
        shopItems.tags["HIGHVALUE"][i] = true 
    end

    if v.tags["LOWVALUE"] then
        shopItems.tags["LOWVALUE"] = shopItems.tags["LOWVALUE"] or {}
        shopItems.tags["LOWVALUE"][i] = true 
    end
    return shopItems;
end

ServerShopManager.loadShopPrices = function()    
    local shopItems = ServerData.Bank.GetShopItems()
    shopItems.items = shopItems.items or {}
    shopItems.tags = shopItems.tags or {}
    if shopItems.doInitShopItems then
        shopItems.doInitShopItems = nil
        for i,v in pairs(PZ_EFT_ShopItems_Config.data) do
            shopItems = doTags(shopItems, i, v)
            PZEFT_UTILS.CopyTable(v, shopItems.items[i])
        end
    end
end

Events.PZEFT_ServerModDataReady.Add(ServerShopManager.loadShopPrices)

ServerShopManager.transmitShopItems = function()    
    ServerData.Shop.TransmitShopItems()
end

