require "ClientData"


------------------

local ExtractionPanel = require("EFTUI/DuringMatch/ExtractionPanel")

------------------


LuaEventManager.AddEvent("PZEFT_UpdateExtractionZoneState")

local function ExtractionUpdateEvent()
    if ClientState.IsInRaid == false then return end

    local pl = getPlayer()
    local currentInstanceData = getPlayer():getModData().currentInstance

    --local currentInstanceData = ClientData.PVPInstances.GetCurrentInstance()
    if currentInstanceData and currentInstanceData.id then
        local extractionPoints = currentInstanceData.extractionPoints
        if extractionPoints then
            local playerSquare = pl:getSquare()
            if playerSquare == nil then return end
            local playerPosition = {x = playerSquare:getX(), y = playerSquare:getY(), z = playerSquare:getZ(),}
            for key ,area in ipairs(extractionPoints) do
                if PZEFT_UTILS.IsInRectangle(playerPosition, area) then
                    print("Player is in the rectangle - " .. tostring(key))
                    if not ClientState.IsInExtractionArea then
                        ClientState.IsInExtractionArea = true
                        --print("Triggering PZEFT_UpdateExtractionZoneState to true")
                        triggerEvent("PZEFT_UpdateExtractionZoneState", key, true)
                        --return      -- if it's true, let's return here instead of cycling
                    end
                else
                    --print("Player is NOT in the rectangle - " .. tostring(key))
                    if ClientState.IsInExtractionArea then
                        ClientState.IsInExtractionArea = false
                        --print("Triggering PZEFT_UpdateExtractionZoneState to false")
                        triggerEvent("PZEFT_UpdateExtractionZoneState", key, false)
                    end
                end
            end
        end
    else
        ClientState.IsInExtractionArea = false
    end
end

Events.EveryOneMinute.Add(ExtractionUpdateEvent)


-------------------------------------------------


EFT_ExtractionHandler = {}

function EFT_ExtractionHandler.DoExtraction()
    print("Extracting player")

    -- TODO Starts client countdown, get the time directly from the ExtractionPoint table
    sendClientCommand("PZEFT-PvpInstances", "RequestExtraction", {})
end

local function HandleExtraction(key, state)
    if state then

        if EFT_ExtractionHandler.area == nil then
            EFT_ExtractionHandler.area = key
        end

        if ExtractionPanel.instance then
            if not ExtractionPanel.instance:getIsVisible() then
                ExtractionPanel.Open()
            end
        else
            ExtractionPanel.Open()
        end
    else
        if EFT_ExtractionHandler.area ~= key then return else
            EFT_ExtractionHandler.area = nil
            if ExtractionPanel.instance and ExtractionPanel.instance:getIsVisible() then
                ExtractionPanel.Close()
            end
        end
    end
end

Events.PZEFT_UpdateExtractionZoneState.Add(HandleExtraction)