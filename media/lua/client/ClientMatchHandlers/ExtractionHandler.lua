require "ClientData"

--TO PAO: Subscribe to this event to check for when player enters and exists extraction, for countdown.
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
            local playerPosition = {x = playerSquare:getX(), y = playerSquare:getY(), z = playerSquare:getZ(),}
            for key ,area in ipairs(extractionPoints) do
                if PZEFT_UTILS.IsInRectangle(playerPosition, area) then
                    print("Player is in the rectangle - " .. tostring(key))
                    if not ClientState.IsInExtractionArea then
                        ClientState.IsInExtractionArea = true
                        --print("Triggering PZEFT_UpdateExtractionZoneState to true")
                        triggerEvent("PZEFT_UpdateExtractionZoneState", {state = true})
                        --return      -- if it's true, let's return here instead of cycling
                    end
                else
                    --print("Player is NOT in the rectangle - " .. tostring(key))
                    if ClientState.IsInExtractionArea then
                        ClientState.IsInExtractionArea = false
                        --print("Triggering PZEFT_UpdateExtractionZoneState to false")
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


EFT_ExtractionHandler = {}
EFT_ExtractionHandler.addedOption = false

function EFT_ExtractionHandler.DoExtraction()
    print("Extracting player")

    sendClientCommand("PZEFT-PvpInstances", "RequestExtraction", {})
    -- TeleportManager.Teleport(player, spawnPoint.x, spawnPoint.y, spawnPoint.z)
    -- sendServerCommand(player, "PZEFT", "SetClientStateIsInRaid", {value = true})
    -- ClientSafehouseInstanceHandler.refreshSafehouseAllocation()
end

function EFT_ExtractionHandler.AddExtractOption(player, context, worldObjects, test)
    if test then return true end
    context:addOption("Extract", worldObjects, EFT_ExtractionHandler.DoExtraction, player)
end



local function HandleExtraction(args)
    --print("Running HandleExtraction")
    if args.state == true then
        if EFT_ExtractionHandler.addedOption == false then
            Events.OnFillWorldObjectContextMenu.Add(EFT_ExtractionHandler.AddExtractOption)
            EFT_ExtractionHandler.addedOption = true
        end
    else
        Events.OnFillWorldObjectContextMenu.Remove(EFT_ExtractionHandler.AddExtractOption)
        EFT_ExtractionHandler.addedOption = false
    end
end

Events.PZEFT_UpdateExtractionZoneState.Add(HandleExtraction)