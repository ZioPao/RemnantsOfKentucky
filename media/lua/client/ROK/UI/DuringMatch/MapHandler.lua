local ClientState = require("ROK/ClientState")

-- TODO Reference from base game to open map items
--     local playerObj = getSpecificPlayer(player)
--     if luautils.haveToBeTransfered(playerObj, map) then
--         local action = ISInventoryTransferAction:new(playerObj, map, map:getContainer(), playerObj:getInventory())
--         action:setOnComplete(ISInventoryPaneContextMenu.onCheckMap, map, player)
--         ISTimedActionQueue.add(action)
--         return
--     end

--     if JoypadState.players[player+1] then
--         local inv = getPlayerInventory(player)
--         local loot = getPlayerLoot(player)
--         inv:setVisible(false)
--         loot:setVisible(false)
--     end

--     local titleBarHgt = ISCollapsableWindow.TitleBarHeight()
--     local x = getPlayerScreenLeft(player) + 20
--     local y = getPlayerScreenTop(player) + 20
--     local width = getPlayerScreenWidth(player) - 20 * 2
--     local height = getPlayerScreenHeight(player) - 20 * 2 - titleBarHgt

--     local mapUI = ISMap:new(x, y, width, height, map, player);
--     mapUI:initialise();
--     local wrap = mapUI:wrapInCollapsableWindow(map:getName(), false, ISMapWrapper);
--     wrap:setInfo(getText("IGUI_Map_Info"));
--     wrap:setWantKeyEvents(true);
--     mapUI.wrap = wrap;
--     wrap.mapUI = mapUI;
-- --    mapUI.render = ISMap.noRender;
-- --    mapUI.prerender = ISMap.noRender;
--     map:doBuildingStash();
--     wrap:setVisible(true);
--     wrap:addToUIManager();
--     if JoypadState.players[player+1] then
--         setJoypadFocus(player, mapUI)
--     end


---@diagnostic disable: undefined-field, undefined-global
---@class MapHandler
---@field symbolsAPI WorldMapSymbols
local MapHandler = {}


---@param symbolsAPI WorldMapSymbols
---@return table
function MapHandler:new(symbolsAPI)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.symbolsAPI = symbolsAPI
    return o
end

function MapHandler:write()
    local currentInstanceData = ClientData.PVPInstances.GetCurrentInstance()
    if currentInstanceData == nil then
        debugPrint("Trying to draw extraction points, but current pvp instance is null on this client")
        return
    end


    -- FIX Already mapped to current instnace
    local extractionPoints = currentInstanceData.extractionPoints

    --Loop through extraction points and add the note on the map
    for i = 1, #extractionPoints do
        local singleExtractionPoint = extractionPoints[i]

        local x = singleExtractionPoint.x1 - (currentInstanceData.x*300)
        local y = singleExtractionPoint.y1 - (currentInstanceData.y*300)

        debugPrint("Ext Point: x=" .. tostring(x) .. ", y=" .. tostring(y))


        local iconSymbol = self.symbolsAPI:addTexture("PZEFT-Exit", x, y)

        if singleExtractionPoint.isRandom then
            --debugPrint("Found random extraction point, adding it to the map")
            iconSymbol:setRGBA(0, 0.25, 0, 1.0)
        else
            --debugPrint("Found permanent extraction point, adding it to the map")
            iconSymbol:setRGBA(0.25, 0, 0, 1.0)
        end

        iconSymbol:setAnchor(0.0, 0.0)

    end
end

function MapHandler:clear()
    self.symbolsAPI:clear()
end

function MapHandler:deactivate()
    if self.modal then
        self.modal.no:forceClick()
        self.modal = nil
    end
end

-------------------

--- Handles writing symbols on the map to show the extraction points
---@param cleanOnly boolean Wheter or not to add the symbols after cleaning
function ISWorldMap.HandleEFTExits(cleanOnly)
    local playerNum = getPlayer():getPlayerNum()
    ISWorldMap.ShowWorldMap(playerNum)

    local function TryHandleMapSymbols()
        debugPrint("Trying to set the symbols and closing the map")
        if ISWorldMap_instance == nil then return end
        debugPrint("Found ISWorldMap_instance")
        if ISWorldMap_instance.mapAPI == nil then return end
        debugPrint("Found ISWorldMap_instance map API")

        local symbolsApi = ISWorldMap_instance.mapAPI:getSymbolsAPI()
        local mapHandler = MapHandler:new(symbolsApi)
        mapHandler:clear()

        if cleanOnly~= nil and cleanOnly == false then
            mapHandler:write()
        end

        -- Handle autocentering and zooming on the zone
        local settings = WorldMapSettings.getInstance()
        local zoom = settings:getDouble("WorldMap.Zoom", 50.0)
        ISWorldMap_instance:onCenterOnPlayer()
        ISWorldMap_instance.mapAPI:setZoom(zoom)


        ISWorldMap.HideWorldMap(playerNum)

        Events.OnTickEvenPaused.Remove(TryHandleMapSymbols)
    end


    Events.OnTickEvenPaused.Add(TryHandleMapSymbols)

end



Events.PZEFT_ClientModDataReady.Add(function(key)
    if key == EFT_ModDataKeys.PVP_CURRENT_INSTANCE_ID then
        ISWorldMap.HandleEFTExits(false)
    end
end)

Events.PZEFT_OnSuccessfulTeleport.Add(function()
    -- If we're in a raid, we need to reset the correct symbols.
    -- If we're not, we're gonna just clean them off the map
    ISWorldMap.HandleEFTExits(not ClientState.GetIsInRaid())
end)




-------------------------------------------
--* LootMap section

require 'ISUI/Maps/ISMapDefinitions'

LootMaps.Init.BriaIslandMap = function(mapUI)
    local mapAPI = mapUI.javaObject:getAPIv1()
    MapUtils.initDirectoryMapData(mapUI, 'media/maps/PZ-EFT')
    MapUtils.initDefaultStyleV1(mapUI)
    --replaceWaterStyle(mapUI)
    mapAPI:setBoundsInSquares(0, 0, 900, 600)
--	overlayPNG(mapUI, 11093, 9222, 0.666, "badge", "media/textures/worldMap/MuldraughBadge.png")
    --overlayPNG(mapUI, lvGridX1(1), lvGridY1(2), 1.0, "legend", "media/textures/worldMap/LouisvilleBadge.png")
    MapUtils.overlayPaper(mapUI)

    local symbolsApi = mapAPI:getSymbolsAPI()
    local mapHandler = MapHandler:new(symbolsApi)
    mapHandler:clear()
    mapHandler:write()
    
end