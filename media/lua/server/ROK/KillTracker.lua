---comment
---@param playerObj IsoPlayer
local function OnCharacterDeath(playerObj)
    if playerObj:isZombie() then return end

    local killerObj = playerObj:getAttackedBy()

    if killerObj and killerObj ~= playerObj then
        -- TODO Add to kill count, send it back to client

    end
end

Events.OnCharacterDeath.Add(OnCharacterDeath)
