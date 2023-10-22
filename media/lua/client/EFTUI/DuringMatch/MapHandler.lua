local EFTMapHandler = {}

function EFTMapHandler:new(symbolsAPI)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.symbolsAPI = symbolsAPI
    return o
end

function EFTMapHandler:write()
    local instance = getPlayer():getModData().currentInstance
    local extractionPoints = instance.extractionPoints

    --Loop through extraction points and add the note on the map
    for i = 1, #extractionPoints do
        local singleExtractionPoint = extractionPoints[i]

        local x = instance.x + (singleExtractionPoint.x1 + singleExtractionPoint.x2)/2
        local y = instance.y + (singleExtractionPoint.y1 + singleExtractionPoint.y2)/2
        local iconSymbol = self.symbolsAPI:addTexture("PZEFT-Exit", x, y)

        iconSymbol:setRGBA(0, 0, 0, 1.0)
        iconSymbol:setAnchor(0.0, 0.0)
        iconSymbol:setScale(ISMap.SCALE/6)

    end
end

function EFTMapHandler:clear()
    self.symbolsAPI:clear()
end

function EFTMapHandler:deactivate()
    if self.modal then
        self.modal.no:forceClick()
        self.modal = nil
    end
end

-------------------

--- Handles writing symbols on the map to show the extraction points
---@param playerNum number
---@param cleanOnly boolean Wheter or not to add the symbols after cleaning
ISWorldMap.HandleEFTExits = function(playerNum, cleanOnly)
    ISWorldMap.ShowWorldMap(playerNum)

    local function TryHandleMapSymbols()
        print("Trying to set the symbols and closing the map")
        if ISWorldMap_instance == nil then return end
        print("Found ISWorldMap_instance")
        if ISWorldMap_instance.mapAPI == nil then return end
        print("Found ISWorldMap_instance map API")

        local symbolsApi = ISWorldMap_instance.mapAPI:getSymbolsAPI()
        local eftMapHandler = EFTMapHandler:new(symbolsApi)
        eftMapHandler:clear()

        if cleanOnly~= nil and cleanOnly == false then
            eftMapHandler:write()
        end
        ISWorldMap.HideWorldMap(playerNum)

        Events.OnTickEvenPaused.Remove(TryHandleMapSymbols)
    end


    Events.OnTickEvenPaused.Add(TryHandleMapSymbols)

end
