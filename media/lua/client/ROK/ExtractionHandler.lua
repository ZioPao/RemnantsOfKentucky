require "ROK/ClientData"
local ExtractionPanel = require("ROK/UI/DuringMatch/ExtractionPanel")
local ClientState = require("ROK/ClientState")
LuaEventManager.AddEvent("PZEFT_UpdateExtractionZoneState")
local os_time = os.time
------------------

---@class ExtractionHandler
---@field key string
local ExtractionHandler = {}

---Starts the loop to handle the event
---@param isInRaid boolean
function ExtractionHandler.ToggleEvent(isInRaid)
    if isInRaid == true then
        Events.OnTick.Add(ExtractionHandler.RunEvent)
    else
        Events.OnTick.Remove(ExtractionHandler.RunEvent)
    end

end
Events.PZEFT_UpdateClientStatus.Add(ExtractionHandler.ToggleEvent)

---Triggers PZEFT_UpdateExtractionZoneState if player is in an extraction zone
function ExtractionHandler.RunEvent()
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
        debugPrint("Extract now!")
        sendClientCommand(EFT_MODULES.Match, "RequestExtraction", {})
        ExtractionPanel.Close()
        Events.OnTick.Remove(ExtractionHandler.HandleTimer)
    end
end

---Will run the extraction on the client
function ExtractionHandler.DoExtraction()
    local currentInstanceData = getPlayer():getModData().currentInstance
    ExtractionHandler.stopTime = os_time() + currentInstanceData.extractionPoints[ExtractionHandler.key].time
    Events.OnTick.Add(ExtractionHandler.HandleTimer)
end



return ExtractionHandler