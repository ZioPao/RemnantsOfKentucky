require "ClientData"
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
            triggerEvent("PZEFT_UpdateExtractionZoneState", key)
        end
    end
end

Events.EveryOneMinute.Add(ExtractionUpdateEvent)

-------------------------------------------------

---@class EFT_ExtractionHandler
EFT_ExtractionHandler = {}
local os_time = os.time

function EFT_ExtractionHandler.HandleTimer()
    local cTime = os_time()

    -- TODO Check if player is still in zone. If not, stop timer
    --print(cTime)
    print(ClientState.ExtractionStatus[EFT_ExtractionHandler.key])
    if ClientState.ExtractionStatus[EFT_ExtractionHandler.key] == nil then
        Events.OnTick.Remove(EFT_ExtractionHandler.HandleTimer)
        print("Player not in extraction zone anymore")
        return
    end

    local formattedTime = string.format("%d", EFT_ExtractionHandler.stopTime - cTime)
    ExtractionPanel.instance:setExtractButtonTitle(formattedTime)

    if cTime >= EFT_ExtractionHandler.stopTime then
        print("Extract now!")
        sendClientCommand("PZEFT-PvpInstances", "RequestExtraction", {})
        ExtractionPanel.Close()
        Events.OnTick.Remove(EFT_ExtractionHandler.HandleTimer)
    end
end

function EFT_ExtractionHandler.DoExtraction()
    local currentInstanceData = getPlayer():getModData().currentInstance
    EFT_ExtractionHandler.stopTime = os_time() + currentInstanceData.extractionPoints[EFT_ExtractionHandler.key].time
    Events.OnTick.Add(EFT_ExtractionHandler.HandleTimer)
end



local function HandleExtraction(key)
    if EFT_ExtractionHandler.key and EFT_ExtractionHandler.key ~= key then return end

    if ClientState.ExtractionStatus[key] then
        EFT_ExtractionHandler.key = key
        ExtractionPanel.Open()
    else
        EFT_ExtractionHandler.key = nil
        ExtractionPanel.Close()
    end


    -- if ClientState.ExtractionStatus[key] == true and ExtractionPanel.instance == nil then
    --     print("Extraction Status i true for " .. key)
    --     ExtractionPanel.Toggle()
    --     -- if state then
    --     --     EFT_ExtractionHandler.key = key
    --     --     ExtractionPanel.Open()
    --     -- end
    -- else

    -- end


    -- if ClientState.ExtractionStatus[key] and state == false then
    --     print("Closing ExtractionPanel")
    --     ExtractionPanel.Close()
    -- elseif state then
    --     print("Opening ExtractionPanel")
    --     EFT_ExtractionHandler.key = key
    --     ExtractionPanel.Open()
    -- end
end

Events.PZEFT_UpdateExtractionZoneState.Add(HandleExtraction)