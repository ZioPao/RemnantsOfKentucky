
--* DISABLE BOREDOM AND UNHAPPYNESS

local function ResetBoredomAndUnhappyness()
    local bd = getPlayer():getBodyDamage()
    bd:setBoredomLevel(0)
    bd:setUnhappynessLevel(0)
end

Events.EveryOneMinute.Add(ResetBoredomAndUnhappyness)



local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")


--* DISABLE SLEDGEHAMMERS IN SAFEHOUSE TO PREVENT FUCKY THINGS
local og_ISDestroyStuffActionIsValid = ISDestroyStuffAction.isValid

function ISDestroyStuffAction:isValid()
    local ogReturn = og_ISDestroyStuffActionIsValid(self)

    if SafehouseInstanceHandler.IsInSafehouse() then
        return false
    end

    return ogReturn
end


--* DISABLE SCRAPPING THROUGH CONTEXT MENU WHILE IN STATIC ROOM


local og_ISMoveablesActionIsValid = ISMoveablesAction.isValid
function ISMoveablesAction:isValid()

    local ogReturn = og_ISMoveablesActionIsValid(self)

    if SafehouseInstanceHandler.IsInSafehouse() then
        return not SafehouseInstanceHandler.IsInStaticArea(self.square)
    end

    return ogReturn
end