-- TODO When in a match, the player should be able to check out the map to see where extraction points are located
-- TODO We need SymbolsAPI, a way to automatically write at the extraction points location, a way to clear everything at match startup, etc.


-- TODO Make it local
EFTMapHandler = {}

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
    for i=1, #extractionPoints do
		local singleExtractionPoint = extractionPoints[i]
        local x = instance.x + singleExtractionPoint.x
        local y = instance.y + singleExtractionPoint.y

        local iconSymbol = self.symbolsAPI:addTexture("PZEFT-Exit", x, y)
		iconSymbol:setRGBA(0, 0, 0, 1.0)
		iconSymbol:setAnchor(0.0, 0.0)
		iconSymbol:setScale(ISMap.SCALE)
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


--!!! JUST A PROOF OF CONCEPT HERE!

local og_ISWorldMapInstantiate = ISWorldMap.instantiate
function ISWorldMap:instantiate()
    print("Instantiating ISWorldMap")
    og_ISWorldMapInstantiate(self)

    -- TODO Should be triggered when a match is starting?
    self.eftMapHandler = EFTMapHandler:new(self.mapAPI:getSymbolsAPI())
    self.eftMapHandler:clear()
    self.eftMapHandler:write()
end
-- getWorldMarkers():addGridSquareMarker("circle_center", "circle_only_highlight", sq, r, g, b, true, 1)
-- getWorldMarkers():addPlayerHomingPoint(player, sq:getX(), sq:getY(), data.worldMarkerData.r, data.worldMarkerData.g, data.worldMarkerData.b, 5)