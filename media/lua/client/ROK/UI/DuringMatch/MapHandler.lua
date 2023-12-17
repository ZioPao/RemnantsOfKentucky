---@diagnostic disable: undefined-field, undefined-global
---@class MapHandler
---@field symbolsAPI WorldMapSymbols
local MapHandler = {}


---@param symbolsAPI WorldMapSymbols
---@return table
function MapHandler:new(symbolsAPI)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.symbolsAPI = symbolsAPI
    return o
end

function MapHandler:write()
    local instance = getPlayer():getModData().currentInstance
    local extractionPoints = instance.extractionPoints

    --Loop through extraction points and add the note on the map
    for i = 1, #extractionPoints do
        local singleExtractionPoint = extractionPoints[i]

        local x = instance.x + (singleExtractionPoint.x1 + singleExtractionPoint.x2)/2 - 5
        local y = instance.y + (singleExtractionPoint.y1 + singleExtractionPoint.y2)/2 - 5
        local iconSymbol = self.symbolsAPI:addTexture("PZEFT-Exit", x, y)

        if singleExtractionPoint.isRandom then
            --debugPrint("Found random extraction point, adding it to the map")
            iconSymbol:setRGBA(0, 0.25, 0, 1.0)
        else
            --debugPrint("Found permanent extraction point, adding it to the map")
            iconSymbol:setRGBA(0.25, 0, 0, 1.0)
        end


        iconSymbol:setAnchor(0.0, 0.0)
        --iconSymbol:setScale(ISMap.SCALE/6)

    end
end

function MapHandler:clear()
    self.symbolsAPI:clear()
end

function MapHandler:deactivate()
    if self.modal then
        self.modal.no:forceClick()
        self.modal = nil
    end
end

-------------------

--- Handles writing symbols on the map to show the extraction points
---@param cleanOnly boolean Wheter or not to add the symbols after cleaning
function ISWorldMap.HandleEFTExits(cleanOnly)
    local playerNum = getPlayer():getPlayerNum()
    ISWorldMap.ShowWorldMap(playerNum)

    local function TryHandleMapSymbols()
        debugPrint("Trying to set the symbols and closing the map")
        if ISWorldMap_instance == nil then return end
        debugPrint("Found ISWorldMap_instance")
        if ISWorldMap_instance.mapAPI == nil then return end
        debugPrint("Found ISWorldMap_instance map API")

        local symbolsApi = ISWorldMap_instance.mapAPI:getSymbolsAPI()
        local mapHandler = MapHandler:new(symbolsApi)
        mapHandler:clear()

        if cleanOnly~= nil and cleanOnly == false then
            mapHandler:write()
        end
        ISWorldMap.HideWorldMap(playerNum)

        Events.OnTickEvenPaused.Remove(TryHandleMapSymbols)
    end


    Events.OnTickEvenPaused.Add(TryHandleMapSymbols)

end

-- If we're in a raid, we need to reset the correct symbols. If we're not, we're gonna just clean them off the map
Events.PZEFT_UpdateClientStatus.Add(function(isInraid)
    ISWorldMap.HandleEFTExits(not isInRaid)
end)