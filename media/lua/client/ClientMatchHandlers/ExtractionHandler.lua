require "ClientData"

--TO PAO: Subscribe to this event to check for when player enters and exists extraction, for countdown.
LuaEventManager.AddEvent("PZEFT_UpdateExtractionZoneState")

local function ExtractionUpdateEvent()
    if ClientState.IsInRaid == false then return end

    local pl = getPlayer()
    local currentInstanceData = getPlayer():getModData().currentInstance

    --local currentInstanceData = ClientData.PVPInstances.GetCurrentInstance()
    if currentInstanceData and currentInstanceData.id then
        -- local instanceId = currentInstanceData.id
        -- local pvpInstances = ClientData.PVPInstances.GetPvpInstances()
        -- local currentInstance = pvpInstances[instanceId]
        local extractionPoints = currentInstanceData.extractionPoints

        -- FIXME Extraction points should have an area, but they're only x,y,z with duplicates x1,y2,z2
        if extractionPoints then
            local playerSquare = pl:getSquare()
            local playerPosition = {x = playerSquare:getX(), y = playerSquare:getY(), z = playerSquare:getZ(),}
            for _,area in ipairs(extractionPoints) do
                if PZEFT_UTILS.IsInRectangle(playerPosition, area) then
                    print("Player is in the rectangle")
                    if not ClientState.IsInExtractionArea then
                        ClientState.IsInExtractionArea = true
                        print("Triggering PZEFT_UpdateExtractionZoneState to true")
                        triggerEvent("PZEFT_UpdateExtractionZoneState", {state = true})
                        --return      -- if it's true, let's return here instead of cycling
                    end
                else
                    print("Player is NOT in the rectangle")
                    if ClientState.IsInExtractionArea then
                        ClientState.IsInExtractionArea = false
                        print("Triggering PZEFT_UpdateExtractionZoneState to false")
                        triggerEvent("PZEFT_UpdateExtractionZoneState", {state = false})
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


local function HandleExtraction(state)
    if state == false then
        print("Not in extraction point")
    else
        print("Player is in extraction point, start countdown?")

    end


end

Events.PZEFT_UpdateExtractionZoneState.Add(HandleExtraction)