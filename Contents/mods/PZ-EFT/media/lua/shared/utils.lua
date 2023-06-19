PZEFT_UTILS = PZEFT_UTILS or {}

--- Teleports player to world coordinates
---@param player IsoPlayer
---@param x number
---@param y number
---@param z number
PZEFT_UTILS.TeleportPlayer = function(player, x, y, z)
    assert(player ~= nil, "PZEFT_UTILS.TeleportPlayer: Player cannot be nil");

    player:setX(x)
    player:setY(y)
    player:setZ(z)
    player:setLx(x)
    player:setLy(y)
    player:setLz(z)
end

--- Maps world coordinates starting at cell 0,0 to different cell coordinates
---@param coordinateList {x=0,y=0,z=0}
---@param cellX number
---@param cellY number
---@return {{x=0,y=0,z=0}, {x=0,y=0,z=0}}
PZEFT_UTILS.MapWorldCoordinatesToCell = function(coordinateList, cellX, cellY)
    local mappedCoordinates = {}
    for index, point in ipairs(coordinateList) do
        local wX = cellX * 300
        local wY = cellY * 300

        table.insert(mappedCoordinates, {
            x = wX + point.x,
            y = wY + point.y,
            z = point.z
        });
    end

    return mappedCoordinates;
end
