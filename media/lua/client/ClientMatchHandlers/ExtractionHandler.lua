require "ClientData"


------------------

local ExtractionPanel = require("EFTUI/DuringMatch/ExtractionPanel")

------------------


LuaEventManager.AddEvent("PZEFT_UpdateExtractionZoneState")

local function ExtractionUpdateEvent()
    if ClientState.IsInRaid == false then return end

    local pl = getPlayer()
    local currentInstanceData = getPlayer():getModData().currentInstance
    if currentInstanceData == nil or currentInstanceData.id == nil then return end
    local extractionPoints = currentInstanceData.extractionPoints
    if extractionPoints then
        local playerSquare = pl:getSquare()
        if playerSquare == nil then return end
        local playerPosition = {x = playerSquare:getX(), y = playerSquare:getY(), z = playerSquare:getZ(),}
        for key ,area in ipairs(extractionPoints) do
            local isInArea = PZEFT_UTILS.IsInRectangle(playerPosition, area)
            ClientState.ExtractionStatus[key] = isInArea
            triggerEvent("PZEFT_UpdateExtractionZoneState", key, isInArea)
        end
    end
end

Events.EveryOneMinute.Add(ExtractionUpdateEvent)


-------------------------------------------------


EFT_ExtractionHandler = {}
local os_time = os.time

function EFT_ExtractionHandler.HandleTimer()
    local cTime = os_time()
    if cTime >= EFT_ExtractionHandler.stopTime then
        print("Extract now!")
        sendClientCommand("PZEFT-PvpInstances", "RequestExtraction", {})
        Events.OnTick.Remove(EFT_ExtractionHandler.HandleTimer)
    end
end

function EFT_ExtractionHandler.DoExtraction()
    print("Extracting player")
    local currentInstanceData = getPlayer():getModData().currentInstance

    EFT_ExtractionHandler.stopTime = os_time() + currentInstanceData.extractionPoints[EFT_ExtractionHandler.key].time
    Events.OnTick.Add(EFT_ExtractionHandler.HandleTimer)

    -- TODO Starts client countdown, get the time directly from the ExtractionPoint table

end



local function HandleExtraction(key, state)
    print("Running HandleExtraction")
    local currentInstanceData = getPlayer():getModData().currentInstance
    --local extractionPoints = currentInstanceData.extractionPoints

    if ClientState.ExtractionStatus[key] and state == false then
        ExtractionPanel.Close()
    elseif state then
        EFT_ExtractionHandler.key = key
        ExtractionPanel.Open()
    end
end

Events.PZEFT_UpdateExtractionZoneState.Add(HandleExtraction)