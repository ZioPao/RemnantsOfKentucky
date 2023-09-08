require "ClientData"

--TO PAO: Subscribe to this event to check for when player enters and exists extraction, for countdown.
LuaEventManager.AddEvent("PZEFT_UpdateExtractionZoneState")

local function isInExtraction()
    local currentInstanceData = ClientData.PVPInstances.GetCurrentInstance()
    if ClientState.IsInRaid and currentInstanceData and currentInstanceData.id then
        local instanceId = currentInstanceData.id
        local pvpInstances = ClientData.PVPInstances.GetPvpInstances()
        local currentInstance = pvpInstances[instanceId]

        local extractionPoints = currentInstance.extractionPoints

        if extractionPoints then
            local playerSquare = getPlayer():getSquare()
            local playerPosition = {x = playerSquare:getX(), y = playerSquare:getY(), z = playerSquare:getZ(),}
            for _,area in ipairs(extractionPoints) do
                if PZEFT_UTILS.IsInRectangle(playerPosition, area) then
                    if not ClientState.IsInExtractionArea then
                        ClientState.IsInExtractionArea = true
                        triggerEvent("PZEFT_UpdateExtractionZoneState", {state = true})
                    end
                else
                    if ClientState.IsInExtractionArea then
                        ClientState.IsInExtractionArea = false
                        triggerEvent("PZEFT_UpdateExtractionZoneState", {state = false})
                    end
                end
            end
        end
    else
        ClientState.IsInExtractionArea = false
    end
end

local function updateExtractionZoneState(data)
    print("updateExtractionZoneState:")
    print(data.state)
end

Events.PZEFT_UpdateExtractionZoneState.Add(updateExtractionZoneState)