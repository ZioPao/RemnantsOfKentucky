require "ShopItems/PZ_EFT_ShopItems"
require "ServerData"

ServerShopManager = ServerShopManager or {}

ServerShopManager.loadShopPrices = function()    
    local shopItems = ServerData.Bank.GetShopItems()
    if shopItems.doInitShopItems then
        shopItems.doInitShopItems = nil
        for i,v in pairs(PZ_EFT_ShopItems_Config.data) do
            PZEFT_UTILS.CopyTable(v, shopItems[i])
        end
    end
end

Events.PZEFT_ServerModDataReady.Add(ServerShopManager.loadShopPrices)

ServerShopManager.transmitShopItems = function()    
    ServerData.Bank.TransmitShopItems()
end

