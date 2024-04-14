
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

-- local function GivePlayerBriaIslandMap()
--  -- Hidden item to use the map
-- end

-- Events.OnCreatePlayer.Add(GivePlayerBriaIslandMap)


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

---@param map InventoryItem
---@param player number
local function OpenBriaMap(map, player)
    local playerObj = getSpecificPlayer(player)
    if luautils.haveToBeTransfered(playerObj, map) then
        local action = ISInventoryTransferAction:new(playerObj, map, map:getContainer(), playerObj:getInventory())
        action:setOnComplete(ISInventoryPaneContextMenu.onCheckMap, map, player)
        ISTimedActionQueue.add(action)
        return
    end

    if JoypadState.players[player+1] then
        local inv = getPlayerInventory(player)
        local loot = getPlayerLoot(player)
        inv:setVisible(false)
        loot:setVisible(false)
    end

    local titleBarHgt = ISCollapsableWindow.TitleBarHeight()
    local x = getPlayerScreenLeft(player) + 20
    local y = getPlayerScreenTop(player) + 20
    local width = getPlayerScreenWidth(player) - 20 * 2
    local height = getPlayerScreenHeight(player) - 20 * 2 - titleBarHgt

    local mapUI = ISMap:new(x, y, width, height, map, player);
    mapUI:initialise();
    local wrap = mapUI:wrapInCollapsableWindow(map:getName(), false, ISMapWrapper);
    wrap:setInfo(getText("IGUI_Map_Info"));
    wrap:setWantKeyEvents(true);
    mapUI.wrap = wrap;
    wrap.mapUI = mapUI;
--    mapUI.render = ISMap.noRender;
--    mapUI.prerender = ISMap.noRender;
    map:doBuildingStash();
    wrap:setVisible(true);
    wrap:addToUIManager();
	if JoypadState.players[player+1] then
        setJoypadFocus(player, mapUI)
    end
	mapUI.mapAPI:setBoolean("Players", true)

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
            OpenBriaMap(mapItem, playerNum)
        else
            debugPrint("Couldn't find map item. Something ain't right with this boy")
        end
    end
end