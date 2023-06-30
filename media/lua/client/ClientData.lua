local KEY_SHOP_ITEMS = "PZ-EFT-SHOP-ITEMS"

ClientData = ClientData or {}

ClientData.requestData = function()
    ModData.request(KEY_SHOP_ITEMS)
end

ClientData.OnReceiveGlobalModData = function(key, modData)
	if key == KEY_SHOP_ITEMS then
        ModData.add(key, modData)
    end
end

Events.OnReceiveGlobalModData.Add(ClientData.OnReceiveGlobalModData)

Events.PZEFT_ClientModDataReady.Add(ClientData.requestData)

ClientData.Shop =ClientData.Shop or {}

ClientData.Shop.GetShopItems = function()
    return ModData.getOrCreate(KEY_SHOP_ITEMS)
end