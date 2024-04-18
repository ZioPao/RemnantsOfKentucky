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

Events.OnServerStarted.Add(function()
    if getActivatedMods():contains("UdderlyUpToDate") then
        debugPrint("UdderlyUpToDate in use! Overriding functions")
        require("UdderlyUpToDate")

        --* UDDERLY UP TO DATE OVERRIDE *--
        -- We want to prevent the mod from restarting the server mid-match
        local og_UdderlyUpToDate_pollWorkshop = UdderlyUpToDate.pollWorkshop
        function UdderlyUpToDate.pollWorkshop()
            debugPrint("UdderlyUpToDate polling started")
            local MatchController = require("ROK/MatchController")
            if MatchController.CheckIsMatchRunning() then
                debugPrint("Match is running, can't continue with UdderlyUpToDate")
                return
            end

            og_UdderlyUpToDate_pollWorkshop()
        end
    end
end)
