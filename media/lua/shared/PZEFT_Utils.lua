PZEFT_UTILS = PZEFT_UTILS or {}

--- Maps world coordinates starting at cell 0,0 to different cell coordinates
---@param coordinateList {x=0,y=0,z=0}
---@param cellX number
---@param cellY number
---@param otherArgs list of names of arguments to copy from coordinateList, Example: {"time"}
---@return {{x=0,y=0,z=0}, {x=0,y=0,z=0}}
PZEFT_UTILS.MapWorldCoordinatesToCell = function(coordinateList, cellX, cellY, otherArgs)
    local mappedCoordinates = {}
    for index, point in ipairs(coordinateList) do
        local wX = cellX * 300
        local wY = cellY * 300

        local newEntry = {
            x = wX + point.x,
            y = wY + point.y,
            z = point.z
        }

        if otherArgs then
            for _, arg in ipairs(otherArgs) do
                newEntry[arg] = point[arg]
            end
        end

        table.insert(mappedCoordinates, newEntry)
    end

    return mappedCoordinates
end

PZEFT_UTILS.getSquareStringCoords = function(square)
    return "X"..square.x.."Y"..square.y.."Z"..square.z
end

PZEFT_UTILS.getSurroundingGridCoordinates = function(center, radius)
    local coordinates = {}

    local str = PZEFT_UTILS.getSquareStringCoords(center)
    coordinates[str] = true

    for xOffset = -radius, radius do
      for yOffset = -radius, radius do
        local newX = center.x + xOffset
        local newY = center.y + yOffset
  
        local point = { x = newX, y = newY, z = center.z }
        str = PZEFT_UTILS.getSquareStringCoords(point)
        coordinates[str] = true
      end
    end
  
    return coordinates
end

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

--- Add items to a container
---@param items Table Of {"Base.ItemName" = quantity}
---@param container IsoContainer
PZEFT_UTILS.AddItems = function(items, container)
    for itemName, quantity in pairs(items) do
        container:AddItem(itemName, quantity)
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

PZEFT_UTILS.GetCellOfPlayer = function(player)
    if not player then return end

    local psq = player:getSquare()

    local x = psq:getX()
    local y = psq:getY()

    local cx = math.floor(x / 300)
    local cy = math.floor(y / 300)

    return {x = cx, y = cy}
end

--- Copy orig into result
---@param orig Table
---@param result Table
PZEFT_UTILS.CopyTable = function(orig, result)
    local copy
    if type(orig) == "table" then
        copy = {}
        for key, value in pairs(orig) do
            copy[key] = PZEFT_UTILS.CopyTable(value)
        end
    else
        copy = orig
    end
    result = copy
end

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

PZEFT_UTILS.GetObjectModData = function(obj)
    local md = obj:getModData()
    md.PZEFT = md.PZEFT or {}
    return md.PZEFT
end

PZEFT_UTILS.GetPlayerModData = function(obj)
    return PZEFT_UTILS.GetObjectModData(getPlayer())
end