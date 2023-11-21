local KEY_SHOP_ITEMS = "PZ-EFT-SHOP-ITEMS"
local KEY_PVP_INSTANCES = "PZ-EFT-PVP-INSTANCES"
local KEY_PVP_CURRENTINSTANCE = "PZ-EFT-PVP-CURRENTINSTANCE"

LuaEventManager.AddEvent("PZEFT_ClientModDataReady")
LuaEventManager.AddEvent("PZEFT_UpdateClientStatus")

----------------------------------------------------------------------------

---@class ClientData
ClientData = ClientData or {}

function ClientData.RequestData()
    ModData.request(KEY_SHOP_ITEMS)
    ModData.request(KEY_PVP_CURRENTINSTANCE)
    ModData.request(KEY_PVP_INSTANCES)
end
Events.PZEFT_ClientModDataReady.Add(ClientData.RequestData)

function ClientData.OnReceiveGlobalModData(key, modData)
	if key == KEY_SHOP_ITEMS then
        ModData.add(key, modData)
    elseif key == KEY_PVP_CURRENTINSTANCE then
        ModData.add(key, modData)
    elseif key == KEY_PVP_INSTANCES then
        ModData.add(key, modData)
    end
end

Events.OnReceiveGlobalModData.Add(ClientData.OnReceiveGlobalModData)

--------------------------------------

ClientData.PVPInstances = ClientData.PVPInstances or {}

function ClientData.PVPInstances.GetPvpInstances()
    return ModData.getOrCreate(KEY_PVP_INSTANCES)
end

function ClientData.PVPInstances.GetCurrentInstance()
    return ModData.getOrCreate(KEY_PVP_CURRENTINSTANCE)
end

--------------------------------------

ClientData.Shop = ClientData.Shop or {}

function ClientData.Shop.GetShopItems()
    return ModData.getOrCreate(KEY_SHOP_ITEMS)
end