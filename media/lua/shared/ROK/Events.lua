if isClient() then

    --* ClientState.lua
    LuaEventManager.AddEvent("PZEFT_IsInRaidChanged")
    LuaEventManager.AddEvent("PZEFT_ClientNowInRaid")
    LuaEventManager.AddEvent("PZEFT_ClientNotInRaidAnymore")

    LuaEventManager.AddEvent("PZEFT_MatchNowRunning")
    LuaEventManager.AddEvent("PZEFT_MatchNotRunningAnymore")


    --* ClientEventHandler.lua
    LuaEventManager.AddEvent("PZEFT_OnPlayerInitDone")

    --* ClientCommon.lua
    LuaEventManager.AddEvent("PZEFT_OnSuccessfulTeleport")

    --* ClientData.lua
    LuaEventManager.AddEvent("PZEFT_ClientModDataReady")

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
    LuaEventManager.AddEvent("PZEFT_OnMatchStart")
    LuaEventManager.AddEvent("PZEFT_OnMatchEnd")

    --* ServerData.lua    
    LuaEventManager.AddEvent("PZEFT_ServerModDataReady")

end