-- TODO Base it on ISWorldMapSymbols
-- TODO When in a match, the player should be able to check out the map to see where extraction points are located
-- TODO We need SymbolsAPI, a way to automatically write at the extraction points location, a way to clear everything at match startup, etc.

local EFTMapHandler = ISWorldMapSymbolTool:derive("EFTMapHandler")

function EFTMapHandler:new(symbolsUI, instanceID)
	local o = ISWorldMapSymbolTool.new(self, symbolsUI)

    o.instanceID = instanceID
	return o
end

function EFTMapHandler:activate()
    -- TODO Should be triggered when a match is starting

    -- TODO Get extraction points list
    local extractionPoints = {{x=1, y=1}, {x=2, y=4}}

    --TODO Get relative coordinates based on the instance id
    local instanceCoords = {x=1, y=1}

    -- TODO Loop through extraction points and add the note on the map

    for i=1, #extractionPoints do
        local textString = "test"

		local singleExtractionPoint = extractionPoints[i]
        
        local x = instanceCoords.x + singleExtractionPoint.x
        local y = instanceCoords.y + singleExtractionPoint.y

        local textSymbol = self.symbolsAPI:addUntranslatedText(textString, UIFont.Handwritten, x, y)
		textSymbol:setRGBA(1, 1, 1, 1.0)
		textSymbol:setAnchor(0.0, 0.0)
		textSymbol:setScale(ISMap.SCALE)
    end

end

function EFTMapHandler:clean()
	-- TODO Clean everything else. Must be triggered when a player enters the game (?)
end

function EFTMapHandler:deactivate()
	if self.modal then
		self.modal.no:forceClick()
		self.modal = nil
	end
end
