
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


local og_ISWorldMenuElementsContextDisassemble = ISWorldMenuElements.ContextDisassemble
function ISWorldMenuElements.ContextDisassemble()
    if SafehouseInstanceHandler.IsInSafehouse() and SafehouseInstanceHandler.IsInStaticArea(getPlayer():getSquare()) then
        return
    end

    og_ISWorldMenuElementsContextDisassemble()

end


--* MAP HANDLING *--

local function GivePlayerBriaIslandMap()
    debugPrint("Giving new player bria island map")
    local player = getPlayer()
    player:getInventory():AddItem("ROK.BriaIslandMap")      -- Hidden item to use the map
end

Events.OnNewGame.Add(GivePlayerBriaIslandMap)


local og_ISMapWrapper_new = ISMapWrapper.new
function ISMapWrapper:new(x, y, width, height)
    local o = og_ISMapWrapper_new(self, x, y, width, height)
    ISMapWrapper.instance = o
    return o
end


local ClientState = require("ROK/ClientState")

local og_ISWorldMap_ToggleWorldMap = ISWorldMap.ToggleWorldMap
function ISWorldMap.ToggleWorldMap(playerNum)

    ISWorldMap.isAdminEftMap = isAdmin() and isKeyDown(Keyboard.KEY_LSHIFT)
    if ISWorldMap.isAdminEftMap then
        return og_ISWorldMap_ToggleWorldMap(playerNum)
    else
        if not ClientState.GetIsInRaid() then return end
        if ISMapWrapper.instance and ISMapWrapper.instance:getIsVisible() then
            ISMapWrapper.instance:close()
            return
        end

        return og_ISWorldMap_ToggleWorldMap(playerNum)
    end

end


local og_ISWorldMap_ShowWorldMap = ISWorldMap.ShowWorldMap
function ISWorldMap.ShowWorldMap(playerNum)
    if not ISWorldMap.IsAllowed() then
        return
    end

    if ISWorldMap.isAdminEftMap then
        return og_ISWorldMap_ShowWorldMap(playerNum)
    else
        local pl = getPlayer()
        local plInv = pl:getInventory()

        local mapItem = plInv:FindAndReturn("ROK.BriaIslandMap")
        if mapItem then
            ISInventoryPaneContextMenu.onCheckMap(mapItem, playerNum)
        else
            debugPrint("Couldn't find map item. Something ain't right with this boy")
        end
    end
end