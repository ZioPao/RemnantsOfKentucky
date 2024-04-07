local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")

--* DISABLE PICKING UP CRATES AND PC IN SAFEHOUSE

local os_ISMoveableCursorIsValid = ISMoveableCursor.isValid
---@param _square IsoGridSquare
---@return boolean
function ISMoveableCursor:isValid(_square)
    local isValid = os_ISMoveableCursorIsValid(self, _square)
    if SafehouseInstanceHandler.IsInSafehouse() then
        debugPrint("Player is in safehouse, checking static area")
        isValid = not SafehouseInstanceHandler.IsInStaticArea(_square)

        if not isValid then
            self.colorMod = ISMoveableCursor.invalidColor
        end
    end

    return isValid
end
