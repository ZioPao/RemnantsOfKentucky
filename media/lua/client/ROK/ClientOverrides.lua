
--* DISABLE BOREDOM AND UNHAPPYNESS

local function ResetBoredomAndUnhappyness()
    local bd = getPlayer():getBodyDamage()
    bd:setBoredomLevel(0)
    bd:setUnhappynessLevel(0)
end

Events.EveryOneMinute.Add(ResetBoredomAndUnhappyness)


--* DISABLE SCRAPPING THROUGH CONTEXT MENU WHILE IN STATIC ROOM
local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")


local og_ISMoveablesActionIsValid = ISMoveablesAction.isValid
function ISMoveablesAction:isValid()

    local ogReturn = og_ISMoveablesActionIsValid(self)

    if SafehouseInstanceHandler.IsInSafehouse() then
        return not SafehouseInstanceHandler.IsInStaticArea(self.square)
    end

    return ogReturn
end