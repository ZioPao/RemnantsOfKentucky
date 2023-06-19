PZEFT_UTILS = PZEFT_UTILS or {}

PZEFT_UTILS.TeleportPlayer = function(player, x, y, z)
    assert(player ~= nil, "PZEFT_UTILS.TeleportPlayer: Player cannot be nil");
    
    player:setX(x)
    player:setY(y)
    player:setZ(z)
    player:setLx(x)
    player:setLy(y)
    player:setLz(z)
end