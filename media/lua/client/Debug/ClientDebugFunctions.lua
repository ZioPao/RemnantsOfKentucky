function printPlayerModData()
    local md = PZEFT_UTILS.GetPlayerModData()
    PZEFT_UTILS.PrintTable(md)
end



local function LoopHighlightExtractionPoints()
    local instance = getPlayer():getModData().currentInstance
    local extractionPoints = instance.extractionPoints
    local hc = getCore():getBadHighlitedColor()

    for i = 1, #extractionPoints do
        local singleExtractionPoint = extractionPoints[i]
        local x1 = instance.x + singleExtractionPoint.x1
        local y1 = instance.y + singleExtractionPoint.y1

        local x2 = instance.x + singleExtractionPoint.x2
        local y2 = instance.y + singleExtractionPoint.y2

        local cell = getCell()
        local sq1 = cell:getGridSquare(x1,y1,0)

        if sq1 then
            sq1:getFloor():setHighlightColor(hc)
            sq1:getFloor():setHighlighted(true)
        end

        local sq2 = cell:getGridSquare(x2,y2,0)

        if sq2 then
            sq2:getFloor():setHighlightColor(hc)
            sq2:getFloor():setHighlighted(true)
        end

    end
end


function HighlightExtractionPoints()
    Events.OnTick.Add(LoopHighlightExtractionPoints)
end