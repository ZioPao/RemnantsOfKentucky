local KEY_SHOP_ITEMS = "PZ-EFT-SHOP-ITEMS"
local KEY_PVP_INSTANCES = "PZ-EFT-PVP-INSTANCES"
local KEY_PVP_CURRENTINSTANCE = "PZ-EFT-PVP-CURRENTINSTANCE"

LuaEventManager.AddEvent("PZEFT_ClientModDataReady")
LuaEventManager.AddEvent("PZEFT_UpdateClientStatus")

ClientData = ClientData or {}

ClientData.requestData = function()
    ModData.request(KEY_SHOP_ITEMS)
    ModData.request(KEY_PVP_CURRENTINSTANCE)
    ModData.request(KEY_PVP_INSTANCES)
end

ClientData.OnReceiveGlobalModData = function(key, modData)
	if key == KEY_SHOP_ITEMS then
        ModData.add(key, modData)
    elseif key == KEY_PVP_CURRENTINSTANCE then
        ModData.add(key, modData)
    elseif key == KEY_PVP_INSTANCES then
        ModData.add(key, modData)
    end
end

Events.OnReceiveGlobalModData.Add(ClientData.OnReceiveGlobalModData)

Events.PZEFT_ClientModDataReady.Add(ClientData.requestData)

ClientData.PVPInstances = ClientData.PVPInstances or {}

ClientData.PVPInstances.GetPvpInstances = function()
    return ModData.getOrCreate(KEY_PVP_INSTANCES)
end

ClientData.PVPInstances.GetCurrentInstance = function()
    return ModData.getOrCreate(KEY_PVP_CURRENTINSTANCE)
end

ClientData.Shop =ClientData.Shop or {}

ClientData.Shop.GetShopItems = function()
    return ModData.getOrCreate(KEY_SHOP_ITEMS)
end