---@class ClientData
ClientData = {}

ClientData.extractionTime = -1


function ClientData.RequestPvpInstances()
    ModData.request(EFT_ModDataKeys.PVP_INSTANCES)
end

function ClientData.OnReceiveGlobalModData(key, modData)
    if key == EFT_ModDataKeys.PVP_CURRENT_INSTANCE_ID or key == EFT_ModDataKeys.PVP_INSTANCES or key == EFT_ModDataKeys.SHOP_ITEMS then
        debugPrint("Received modData for " .. key)
        ModData.add(key, modData)

       -- PZEFT_UTILS.PrintTable(modData)

       if key == EFT_ModDataKeys.PVP_CURRENT_INSTANCE_ID then
            debugPrint("Instance id = " .. modData.id)
       end

        -- The client has collected the mod data from the server
        triggerEvent("PZEFT_ClientModDataReady", key)
    end

end

Events.OnReceiveGlobalModData.Add(ClientData.OnReceiveGlobalModData)

--------------------------------------

ClientData.PVPInstances = ClientData.PVPInstances or {}

function ClientData.PVPInstances.GetPvpInstances()
    return ModData.getOrCreate(EFT_ModDataKeys.PVP_INSTANCES)
end

---@return pvpInstanceTable
function ClientData.PVPInstances.GetCurrentInstance()
    local currInstanceIdTab = ModData.get(EFT_ModDataKeys.PVP_CURRENT_INSTANCE_ID)
    local instancesData = ModData.get(EFT_ModDataKeys.PVP_INSTANCES)

    local currentInstance = instancesData[currInstanceIdTab.id]
    return currentInstance
end

--------------------------------------

ClientData.Shop = ClientData.Shop or {}

---@return shopItemsTable
function ClientData.Shop.GetShopItems()
    return ModData.getOrCreate(EFT_ModDataKeys.SHOP_ITEMS)
end

