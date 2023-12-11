PZEFT_UTILS = PZEFT_UTILS or {}

---@alias coords2d {x: number, y : number}
---@alias coords {x : number, y : number, z : number}
---@alias areaCoords {x1 : number, y1 : number, z1 : number, x2 : number, y2 : number, z2: number}

---@alias bankAccountTable {balance : number}
---@alias EFTModData {bankAccount : bankAccountTable, safehouse : coords}

--- Maps world coordinates starting at cell 0,0 to different cell coordinates
---@param coordinateList table<integer, table>
---@param cellX number
---@param cellY number
---@param otherArgs table list of names of arguments to copy from coordinateList, Example: {"time"}
---@return areaCoords?
PZEFT_UTILS.MapWorldCoordinatesToCell = function(coordinateList, cellX, cellY, otherArgs)
    local mappedCoordinates = {}

    --debugPrint("CELLX: " .. tostring(cellX))
    --debugPrint("CELLY: " .. tostring(cellY))

    if not coordinateList then return nil end

    for index, point in ipairs(coordinateList) do
        local wX = cellX * 300
        local wY = cellY * 300
        local newEntry
        if point.x ~= nil then
            newEntry = {
                x = wX + point.x,
                y = wY + point.y,
                z = point.z
            }
        elseif point.x1 ~= nil then
            newEntry = {
                x1 = wX + point.x1,
                y1 = wY + point.y1,
                z1 = point.z1,
                x2 = wX + point.x2,
                y2 = wY + point.y2,
                z2 = point.z2
            }
        end

        if otherArgs then
            for _, arg in ipairs(otherArgs) do
                newEntry[arg] = point[arg]
            end
        end

        table.insert(mappedCoordinates, newEntry)
    end

    return mappedCoordinates
end

---@param square coords
---@return string 
PZEFT_UTILS.getSquareStringCoords = function(square)
    return "X"..square.x.."Y"..square.y.."Z"..square.z
end

---getSurroundingGridCoordinates
---@param center coords
---@param radius number
---@return coords
PZEFT_UTILS.getSurroundingGridCoordinates = function(center, radius)
    local coordinates = {}

    local str = PZEFT_UTILS.getSquareStringCoords(center)
    coordinates[str] = true

    for xOffset = -radius, radius do
      for yOffset = -radius, radius do
        local newX = center.x + xOffset
        local newY = center.y + yOffset

        ---@type coords
        local point = { x = newX, y = newY, z = center.z }
        str = PZEFT_UTILS.getSquareStringCoords(point)
        coordinates[str] = true
      end
    end
  
    return coordinates
end

---Merge IPAIRS
---@param listA table
---@param listB table
---@return table
PZEFT_UTILS.MergeIPairs = function(listA, listB)
    local resultList = {}

    for _, arg in ipairs(listA) do
        table.insert(resultList, arg)
    end

    for _, arg in ipairs(listB) do
        table.insert(resultList, arg)
    end

    return resultList
end

PZEFT_UTILS.PrintTable = function(table, indent)
    if not PZ_EFT_CONFIG.Debug then return end

    if not table then return end

    indent = indent or ""

    for key, value in pairs(table) do
        if type(value) == "table" then
            print(indent .. key .. " (table):")
            PZEFT_UTILS.PrintTable(value, indent .. "  ")
        else
            print(indent .. key .. ":", value)
        end
    end
end

PZEFT_UTILS.PrintArray = function(array, indent)
    if not PZ_EFT_CONFIG.Debug then return end
    indent = indent or ""

    for i=0, array:size() do
        print(i)
        print(array:get(i))
    end
end

--- Add items to a container
---@param items table Of {"Base.ItemName" = quantity}
---@param container ItemContainer
PZEFT_UTILS.AddItems = function(items, container)
    for itemName, quantity in pairs(items) do
        container:AddItem(itemName, quantity)       -- Umbrella is wrong here
    end
end

--- determine if another point falls within the specified north, south, east, and west dimensions of a given point (x, y)
---@param rootX number
---@param rootY number
---@param north number
---@param south number
---@param east number
---@param west number
---@param posX number
---@param posY number
PZEFT_UTILS.IsPointWithinDimensions = function(rootX, rootY, north, south, east, west, posX, posY)
    local minX = rootX - west
    local maxX = rootX + east
    local minY = rootY - north
    local maxY = rootY + south

    return posX >= minX and posX <= maxX and posY >= minY and posY <= maxY
end

---@param player IsoPlayer
---@return coords?
PZEFT_UTILS.GetCellOfPlayer = function(player)
    if not player then return end

    local psq = player:getSquare()

    local x = psq:getX()
    local y = psq:getY()

    local cx = math.floor(x / 300)
    local cy = math.floor(y / 300)

    return {x = cx, y = cy, z=0}
end

-- --- Copy orig into result
-- ---@param orig table
-- ---@param result table
-- PZEFT_UTILS.CopyTable = function(orig, result)
--     local copy
--     if type(orig) == "table" then
--         copy = {}
--         for key, value in pairs(orig) do
--             copy[key] = PZEFT_UTILS.CopyTable(value)
--         end
--     else
--         copy = orig
--     end
--     result = copy
-- end

-- Function to shuffle a table
PZEFT_UTILS.ShuffleTable = function(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

--- Function to pick random key-value pairs from a table without repetitions
PZEFT_UTILS.PickRandomPairsWithoutRepetitions = function(table, count)
    local totalPairs = 0
    for k,v in pairs(table) do
        totalPairs = totalPairs + 1
    end

    if count >= totalPairs then
        return table -- Return the whole table if requested count is greater or equal to the number of pairs
    end

    -- Shuffle the keys of the table randomly
    local shuffledKeys = {}
    for k,v in pairs(table) do
        table.insert(shuffledKeys, k)
    end
    PZEFT_UTILS.ShuffleTable(shuffledKeys)

    -- Select the first 'count' pairs from the shuffled keys
    local pickedPairs = {}
    for i = 1, count do
        local key = shuffledKeys[i]
        pickedPairs[key] = table[key]
    end

    return pickedPairs
end

---Get Object EFT Mod Data
---@param obj IsoObject
---@return EFTModData
PZEFT_UTILS.GetObjectModData = function(obj)
    local md = obj:getModData()
    md.PZEFT = md.PZEFT or {}
    return md.PZEFT
end

---@return EFTModData
PZEFT_UTILS.GetPlayerModData = function()
    return PZEFT_UTILS.GetObjectModData(getPlayer())
end

---Check if the position is within the area
---@param pos coords
---@param area areaCoords
---@return boolean
PZEFT_UTILS.IsInRectangle = function(pos, area)
    local inXRange = (pos.x >= area.x1 and pos.x <= area.x2) or (pos.x >= area.x2 and pos.x <= area.x1)
    local inYRange = (pos.y >= area.y1 and pos.y <= area.y2) or (pos.y >= area.y2 and pos.y <= area.y1)
    local inZRange = (pos.z >= area.z1 and pos.z <= area.z2) or (pos.z >= area.z2 and pos.z <= area.z1)

    -- print("Player: x=" .. pos.x .. ", y=" .. pos.y)
    -- print("Area: x1=".. area.x1 .. ", x2=" .. area.x2 .. ", y1=" .. area.y1 .. ", y2=" .. area.y2 .. ", z1=" .. area.z1 .. ", z2=" .. area.z2)
    -- print("inXRange: " .. tostring(inXRange))
    -- print("inYRange: " .. tostring(inYRange))
    -- print("inZRange: " .. tostring(inZRange))
    -- print("_____________________________________________")


    return inXRange and inYRange and inZRange
end


---@param p1 coords2d
---@param p2 coords2d
---@param p3 coords2d
function PZEFT_UTILS.Sign(p1, p2, p3)
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y)
end

---@param point coords2d
---@param trP1 coords2d Triangle coords 1
---@param trP2 coords2d Triangle coords 2
---@param trP3 coords2d Triangle coords 3
function PZEFT_UTILS.IsInTriangle(point, trP1, trP2, trP3)
    local d1 = PZEFT_UTILS.Sign(point, trP1, trP2)
    local d2 = PZEFT_UTILS.Sign(point, trP2, trP3)
    local d3 = PZEFT_UTILS.Sign(point ,trP3, trP1)

    local hasNeg = (d1 < 0) or (d2 < 0) or (d3 < 0)
    local hasPos = (d1 > 0 ) or (d2 > 0) or (d3 > 0)

    return not(hasNeg and hasPos)
end
