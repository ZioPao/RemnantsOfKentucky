LuaEventManager.AddEvent("PZEFT_OnMatchStart")
LuaEventManager.AddEvent("PZEFT_OnMatchEnd")

if isClient() then
    --* ClientData.lua
    LuaEventManager.AddEvent("PZEFT_ClientModDataReady")
    LuaEventManager.AddEvent("PZEFT_UpdateClientStatus")

    LuaEventManager.AddEvent("PZEFT_LootRecapReady")

    --* BaseScrollItemsPanel.lua
    LuaEventManager.AddEvent("PZEFT_OnChangeSelectedItem")

    --* ExtractionHandler.lua 
    LuaEventManager.AddEvent("PZEFT_UpdateExtractionZoneState")

    --* ButtonsManager.lua
    LuaEventManager.AddEvent("PZEFT_PostISEquippedItemInitialization")

    --* BuySidePanel
    LuaEventManager.AddEvent("PZEFT_OnSuccessfulBuy")

    --* SellSidePanel
    LuaEventManager.AddEvent("PZEFT_OnSuccessfulSell")

    --* SellScrollItemsPanel
    LuaEventManager.AddEvent("PZEFT_OnFailedSellTransfer")

elseif isServer() then

    --* ServerData.lua    
    LuaEventManager.AddEvent("PZEFT_ServerModDataReady")

end