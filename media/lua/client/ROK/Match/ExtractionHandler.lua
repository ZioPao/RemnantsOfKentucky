require "ROK/ClientData"
local ExtractionPanel = require("ROK/UI/DuringMatch/ExtractionPanel")
local ClientState = require("ROK/ClientState")
local os_time = os.time
------------------

---@class ExtractionHandler
---@field key string
---@field stopTime number
local ExtractionHandler = {}

---Starts the loop to handle the event
function ExtractionHandler.ToggleEvent()
    if ClientState.GetIsInRaid() == true then
        debugPrint("Adding ExtractionHandler event")
        Events.OnTick.Add(ExtractionHandler.RunEvent)
    else
        debugPrint("Disabling ExtractionHandler event")
        -- Close it forcefully here
        ExtractionPanel.Close()
        Events.OnTick.Remove(ExtractionHandler.RunEvent)
    end
end

Events.PZEFT_IsInRaidChanged.Add(ExtractionHandler.ToggleEvent)

---Triggers PZEFT_UpdateExtractionZoneState if player is in an extraction zone
function ExtractionHandler.RunEvent()
    local pl = getPlayer()
    local currentInstanceData = ClientData.PVPInstances.GetCurrentInstance()
    if currentInstanceData == nil then
        debugPrint("Current Instance Data is null, can't run ExtractionHandler event")
        return
    end
    local extractionPoints = currentInstanceData.extractionPoints
    if extractionPoints then
        local playerSquare = pl:getSquare()
        if playerSquare == nil then return end
        local playerPosition = { x = playerSquare:getX(), y = playerSquare:getY(), z = playerSquare:getZ(), }
        for key, area in ipairs(extractionPoints) do
            -- Save previous state
            ClientState.previousExtractionPointsStatus[key] = ClientState.extractionPointsStatus[key]


            local isInArea = PZEFT_UTILS.IsInRectangle(playerPosition, area)
            ClientState.extractionPointsStatus[key] = isInArea

            if ClientState.previousExtractionPointsStatus[key] ~= ClientState.extractionPointsStatus[key] then
                -- Now check if isInArea is true or not
                debugPrint("Extraction Point status changed, key=" .. tostring(key))

                if isInArea then
                    ExtractionPanel.Open()
                else
                    ExtractionPanel.Close()
                    Events.OnTick.Remove(ExtractionHandler.HandleTimer)
                end
            end
        end
    end
end

---Runs the timer for the ExtractionHandler. Can be closed and disabled from RunEvent
function ExtractionHandler.HandleTimer()
    local cTime = os_time()
    local formattedTime = string.format("%d", ExtractionHandler.stopTime - cTime)

    if ExtractionPanel.instance then
        ExtractionPanel.instance:setExtractButtonTitle(formattedTime)

        if cTime >= ExtractionHandler.stopTime then
            ExtractionPanel.instance:disableButton() -- To prevent issues in case of lag
            ExtractionHandler.ExecuteExtraction()
        end
    else
        debugPrint("Extraction panel isn't ready")
    end


end

function ExtractionHandler.ExecuteExtraction()
    debugPrint("Extract now!")
    getSoundManager():playUISound("BoatSound") -- "BoatSound"

    sendClientCommand(EFT_MODULES.Match, "RequestExtraction", {})
    ExtractionPanel.Close()
    Events.OnTick.Remove(ExtractionHandler.HandleTimer)
end

---Will run the extraction on the client
function ExtractionHandler.DoExtraction()
    --local currentInstanceData = ClientData.PVPInstances.GetCurrentInstance()

    ExtractionHandler.stopTime = os_time() + ClientState.GetExtractionTime()
    Events.OnTick.Add(ExtractionHandler.HandleTimer)
end

return ExtractionHandler
