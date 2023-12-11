if isClient() then
    --* ClientData.lua
    LuaEventManager.AddEvent("PZEFT_ClientModDataReady")
    LuaEventManager.AddEvent("PZEFT_UpdateClientStatus")

    --* BaseScrollItemsPanel.lua
    LuaEventManager.AddEvent("PZEFT_OnChangeSelectedItem")

    --* ExtractionHandler.lua 
    LuaEventManager.AddEvent("PZEFT_UpdateExtractionZoneState")

    --* ButtonsManager.lua
    LuaEventManager.AddEvent("PZEFT_PostISEquippedItemInitialization")
elseif isServer() then

    --* ServerData.lua    
    LuaEventManager.AddEvent("PZEFT_ServerModDataReady")

end