---@diagnostic disable: undefined-field, undefined-global
---@class MapHandler
---@field symbolsAPI WorldMapSymbols
local MapHandler = MapHandler or {}


---@param symbolsAPI WorldMapSymbols
---@return MapHandler
function MapHandler:new(symbolsAPI)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.symbolsAPI = symbolsAPI
    return o
end

function MapHandler:write()
    local currentInstanceData = ClientData.PVPInstances.GetCurrentInstance()
    if currentInstanceData == nil then
        debugPrint("Trying to draw extraction points, but current pvp instance is null on this client")
        return
    end

    local extractionPoints = currentInstanceData.extractionPoints

    --Loop through extraction points and add the note on the map
    for i = 1, #extractionPoints do
        local singleExtractionPoint = extractionPoints[i]

        local x = currentInstanceData.x + (singleExtractionPoint.x1 + singleExtractionPoint.x2)/2 - 150
        local y = currentInstanceData.y + (singleExtractionPoint.y1 + singleExtractionPoint.y2)/2 -- - 5
        local iconSymbol = self.symbolsAPI:addTexture("PZEFT-Exit", x, y)

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

function MapHandler:clear()
    self.symbolsAPI:clear()
end

-------------------------------------------
--* LootMap section

require 'ISUI/Maps/ISMapDefinitions'

LootMaps.Init.BriaIslandMap = function(mapUI)
    local mapAPI = mapUI.javaObject:getAPIv1()
    MapUtils.initDirectoryMapData(mapUI, 'media/maps/ROK-BriaIsle')
    MapUtils.initDefaultStyleV1(mapUI)
    --replaceWaterStyle(mapUI)
    mapAPI:setBoundsInSquares(0, 0, 900, 600)       -- First map

--	overlayPNG(mapUI, 11093, 9222, 0.666, "badge", "media/textures/worldMap/MuldraughBadge.png")
    --overlayPNG(mapUI, lvGridX1(1), lvGridY1(2), 1.0, "legend", "media/textures/worldMap/LouisvilleBadge.png")
    MapUtils.overlayPaper(mapUI)

    local symbolsApi = mapAPI:getSymbolsAPI()
    local mapHandler = MapHandler:new(symbolsApi)
    mapHandler:clear()
    mapHandler:write()
end