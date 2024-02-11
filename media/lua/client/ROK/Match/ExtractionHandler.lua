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
---@param isInRaid boolean
function ExtractionHandler.ToggleEvent(isInRaid)
    if isInRaid == true then
        Events.OnTick.Add(ExtractionHandler.RunEvent)
    else
        -- Close it forcefully here
        ExtractionPanel.Close()
        Events.OnTick.Remove(ExtractionHandler.RunEvent)
    end

end
Events.PZEFT_UpdateClientStatus.Add(ExtractionHandler.ToggleEvent)

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
        local playerPosition = {x = playerSquare:getX(), y = playerSquare:getY(), z = playerSquare:getZ(),}
        for key ,area in ipairs(extractionPoints) do
            local isInArea = PZEFT_UTILS.IsInRectangle(playerPosition, area)
            ClientState.extractionStatus[key] = isInArea
            triggerEvent("PZEFT_UpdateExtractionZoneState", key)
        end
    end
end

---Triggered when a player enters an extraction area
---@param key string
---@private
function ExtractionHandler.ManageEvent(key)
    if ExtractionHandler.key and ExtractionHandler.key ~= key then return end

    if ClientState.extractionStatus[key] then
        ExtractionHandler.key = key
        ExtractionPanel.Open()
    else
        ExtractionHandler.key = nil
        ExtractionPanel.Close()
    end
end
Events.PZEFT_UpdateExtractionZoneState.Add(ExtractionHandler.ManageEvent)


function ExtractionHandler.HandleTimer()
    local cTime = os_time()
    --print(cTime)
    --debugPrint(ClientState.extractionStatus[ExtractionHandler.key])
    if ClientState.extractionStatus[ExtractionHandler.key] == nil then
        Events.OnTick.Remove(ExtractionHandler.HandleTimer)
        debugPrint("Player not in extraction zone anymore")
        return
    end

    local formattedTime = string.format("%d", ExtractionHandler.stopTime - cTime)
    ExtractionPanel.instance:setExtractButtonTitle(formattedTime)

    if cTime >= ExtractionHandler.stopTime then
        ExtractionPanel.instance:disableButton()        -- To prevent issues in case of lag
        ExtractionHandler.ExecuteExtraction()
    end
end

function ExtractionHandler.ExecuteExtraction()
    debugPrint("Extract now!")
    ExtractionHandler.key = nil     -- Set this to nil for next match. If it stays it's gonna break stuff next round
    sendClientCommand(EFT_MODULES.Match, "RequestExtraction", {})
    ExtractionPanel.Close()
    Events.OnTick.Remove(ExtractionHandler.HandleTimer)
end

---Will run the extraction on the client
function ExtractionHandler.DoExtraction()
    --local currentInstanceData = ClientData.PVPInstances.GetCurrentInstance()

    ExtractionHandler.stopTime = os_time() + ClientState.GetExtractionTime()
    -- + currentInstanceData.extractionPoints[ExtractionHandler.key].time
    Events.OnTick.Add(ExtractionHandler.HandleTimer)
end



return ExtractionHandler