---comment
---@param playerObj IsoPlayer
local function OnCharacterDeath(playerObj)
    if playerObj:isZombie() then return end

    ---@type IsoPlayer
    local killerObj = playerObj:getAttackedBy()

    if killerObj and killerObj ~= playerObj then
        -- Add to kill count, send it back to client
        sendServerCommand(killerObj, EFT_MODULES.KillTracker, 'AddKill', {victimUsername = playerObj:getUsername()})
    end
end

Events.OnCharacterDeath.Add(OnCharacterDeath)
