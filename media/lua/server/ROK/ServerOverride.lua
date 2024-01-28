local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")

--* DISABLE PICKING UP CRATES AND PC IN SAFEHOUSE

local os_ISMoveableCursorIsValid = ISMoveableCursor.isValid
function ISMoveableCursor:isValid( _square )
    local ogReturn = os_ISMoveableCursorIsValid(self, _square)

    if not SafehouseInstanceHandler.IsInSafehouse() then return ogReturn end
    local objects = {}


    -- Pickup and Scrap
    if ISMoveableCursor.mode[self.player] == "pickup" then
        objects = self.objectListCache or self:getObjectList()
    elseif ISMoveableCursor.mode[self.player] == 'rotate' then
        objects = self.objectListCache or self:getScrapObjectList()
    end

    if #objects > 0 then
        if self.objectIndex > #objects or self.objectIndex < 1 then self.objectIndex = 1 end
        if self.objectIndex >= 1 and self.objectIndex <= #objects then
            local moveProps = objects[self.objectIndex].moveProps
            self.origMoveProps = moveProps
            if moveProps.spriteName == 'location_military_generic_01_8' or moveProps.spriteName == 'appliances_com_01_75' then
                debugPrint("Crate or PC in safehouse!")
                return false
            end
        end
    end


    -- Rotate

    if  ISMoveableCursor.mode[self.player] == "rotate" then
        local rotateObject = self.objectListCache or self:getRotateableObject()
        self.objectListCache = rotateObject
        if rotateObject then
            local moveProps = rotateObject.moveProps
            if moveProps.spriteName == 'location_military_generic_01_8' or moveProps.spriteName == 'appliances_com_01_75' then
                debugPrint("Do not rotate crate or pc")
                return false
            end
        end
    end



    return ogReturn

end