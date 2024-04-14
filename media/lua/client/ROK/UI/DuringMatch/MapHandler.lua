--* LootMap section

require 'ISUI/Maps/ISMapDefinitions'

LootMaps.Init.BriaIslandMap = function(mapUI)
    local mapAPI = mapUI.javaObject:getAPIv1()
    MapUtils.initDirectoryMapData(mapUI, 'media/maps/ROK-BriaIsle')
    MapUtils.initDefaultStyleV1(mapUI)
    --replaceWaterStyle(mapUI)

    -- First map => x = 900, y=600
    local currentInstanceData = ClientData.PVPInstances.GetCurrentInstance()
    if currentInstanceData == nil then
        debugPrint("Trying to draw data on the map, but current pvp instance is null on this client")
        return
    end


    local cellSize = 300

    local sizeX = 900
    local sizeY = 600

    local x1 = currentInstanceData.x * cellSize
    local y1 = currentInstanceData.y * cellSize

    local x2 = x1 + sizeX
    local y2 = y1 + sizeY

    debugPrint("MAP BOUNDS => x1=" .. tostring(x1) .. ", y1=" .. tostring(y1) .. ", x2=" .. tostring(x2) .. ", y2=" ..tostring(y2))

    mapAPI:setBoundsInSquares(x1, y1, x2, y2)

--	overlayPNG(mapUI, 11093, 9222, 0.666, "badge", "media/textures/worldMap/MuldraughBadge.png")
    --overlayPNG(mapUI, lvGridX1(1), lvGridY1(2), 1.0, "legend", "media/textures/worldMap/LouisvilleBadge.png")
    MapUtils.overlayPaper(mapUI)

    local symbolsApi = mapAPI:getSymbolsAPI()
    symbolsApi:clear()


    local extractionPoints = currentInstanceData.extractionPoints

    --Loop through extraction points and add the note on the map
    for i = 1, #extractionPoints do
        local singleExtractionPoint = extractionPoints[i]

        local x = currentInstanceData.x + (singleExtractionPoint.x1 + singleExtractionPoint.x2)/2 - 25
        local y = currentInstanceData.y + (singleExtractionPoint.y1 + singleExtractionPoint.y2)/2

        debugPrint("Ext Point: x=" .. tostring(x) .. ", y=" .. tostring(y))


        local iconSymbol = symbolsApi:addTexture("PZEFT-Exit", x, y)

        if singleExtractionPoint.isRandom then
            --debugPrint("Found random extraction point, adding it to the map")
            iconSymbol:setRGBA(0, 0.25, 0, 1.0)
        else
            --debugPrint("Found permanent extraction point, adding it to the map")
            iconSymbol:setRGBA(0.25, 0, 0, 1.0)
        end

        iconSymbol:setAnchor(0.0, 0.0)

    end

end


Events.PZEFT_ClientNowInRaid.Add(function()

    debugPrint("Checking if player has map")

    local plInv = getPlayer():getInventory()
    local mapType = "ROK.BriaIslandMap"

    if not plInv:FindAndReturn(mapType) then
        debugPrint("Giving the player a new map")
        plInv:AddItem(mapType)
    end

end)