---@diagnostic disable: lowercase-global
require("ROK/Config")

function debugPrint(text)
    if PZ_EFT_CONFIG.Debug or isServer() then
        print("PZEFT: " .. tostring(text))
    end
end


function debugPrintAllItems()
    ---@type ArrayList
    local allItems = getScriptManager():getAllItems()
    local json = require("ROK/JSON")
    local STR_JSON_FOLDER = "media/data/"
    local STR_ITEMS_JSON = "items.json"
    local items = {}

    for i=0, allItems:size() - 1 do

        ---@type Item
        local item = allItems:get(i)

        if not item:isHidden() then

            cat = "["

            for y=0, item:getCategories():size() - 1 do

                n = item:getCategories():get(y)

                cat = cat .. n .. ", "
            end

            if item:getDisplayCategory() then
                cat = cat .. item:getDisplayCategory() .. "]"
                debugPrint(item:getDisplayCategory())
            else
                cat = cat .. "]"
            end

            fType = item:getModuleName() .. "." .. item:getName()

            itemTab = {
                fullType = fType,
                name = item:getDisplayName(),
                category = tostring(cat),
                weight = item:getActualWeight(),
                additionalData = {
                
                },
            }


            it = InventoryItemFactory.CreateItem(fType)

            --* Clothing handling
            if instanceof(it, "Clothing") then
                ---@cast it Clothing
                itemTab.additionalData['bulletDefense'] = it:getBulletDefense()
            end

            --* Weapons handling
            if instanceof(it, "HandWeapon") then
                ---@cast it HandWeapon

                itemTab.additionalData['damage'] = (it:getMinDamage() + it:getMaxDamage())/2
            end


            --* Ammo handling

            -- TODO For boxes we need to fetch the associated recipe and get how many bullets there are inside of it
            -- max ammo for clips?



            table.insert(items, itemTab)
        end
    end

    jsonStr = json.stringify(items)
    writer = getModFileWriter('ROK', STR_JSON_FOLDER .. STR_ITEMS_JSON, true, false)
    writer:write(jsonStr)
    writer:close()
end

function debug_getPosition()
    local p = getPlayer()

    local psq = p:getSquare()

    local x = psq:getX()
    local y = psq:getY()

    local cx = math.floor(x / 300)
    local cy = math.floor(y / 300)

    local rx = x - (cx * 300)
    local ry = y - (cy * 300)

    local s = "CellX: " .. cx .. " CellY: " .. cy .. " RelX: " .. rx .. " RelY: " .. ry .. " WorldX: " .. x ..
                  " WorldY: " .. y

    Clipboard.setClipboard(s)
    debugPrint(s)
end

function debug_getZeroPosition(rootx, rooty)
    local p = getPlayer()

    local psq = p:getSquare()

    local x = psq:getX()
    local y = psq:getY()

    local zeroX = x - (rootx * 300)
    local zeroY = y - (rooty * 300)

    local s = "RootCellX: " .. rootx .. " RootCellY: " .. rooty .. " ZeroX: " .. zeroX .. " ZeroY: " .. zeroY

    Clipboard.setClipboard(s)
    print(s)
end

function debug_testCountdown()
    sendClientCommand("PZEFT-Time", "StartCountdown", {stopTime = 30})
end

function debug_testTimer()
    --sendClientCommand("PZEFT-Time", "StartTimer", {stopTime = 30, timeBetweenFunc=5})
end

function debug_wipeInventory()

    ---@param inv InventoryContainer
    local function WipeItems(inv)
        debugPrint("entering container")
        local items = inv:getItems()

        for i=0, items:size() - 1 do
            local val = items:get(i)
            if val then
                local item = items:get(i):getItem()
                debugPrint(item:getFullType())
                if item and instanceof(item, "InventoryContainer") then
                    debugPrint("Container inside container")
                    --WipeItems(item:getInventory())
                else
                    debugPrint("Not container")
                    --ISRemoveItemTool.removeItem(item, getPlayer())
                end
            end
        end
    end

    -- local ClientCommon = require("ROK/ClientCommon")
    -- ClientCommon.WipeInventory()
    local pl = getPlayer()
	for i=0, pl:getWornItems():size()-1 do
		local item = pl:getWornItems():get(i):getItem()

        debugPrint(item:getFullType())
		if item and instanceof(item, "InventoryContainer") then
            debugPrint("Container")
            --PZEFT_UTILS.PrintArray(item:getInventory():getItems())
            WipeItems(item:getInventory())
        else
            debugPrint("Not container")
            --ISRemoveItemTool.removeItem(item, pl)
        end

        debugPrint("______________________")
    end
end


function debug_giveStarterKit()
    local pl = getPlayer()
    local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")
    SafehouseInstanceHandler.GiveStarterKit(pl, true)
    
end

function debug_testAddCrate(amount)
    local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")
    for i=1, amount do
        SafehouseInstanceHandler.TryToAddToCrate("Base.Bandage")
    end
end

function debug_wipeCrates()
    local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")
    SafehouseInstanceHandler.WipeCrates()

end

function debug_getCrateTetris(index, fullType, x, y, isRotated)
    local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")
    local cratesTable = SafehouseInstanceHandler.GetCrates()
    if cratesTable == nil or #cratesTable == 0 then debugPrint("Crates are nil or empty!") return nil end
    local crateObj = cratesTable[index]
    local inv = crateObj:getContainer()
    local grid = ItemContainerGrid.Create(inv, getPlayer():getPlayerNum())
    local item = InventoryItemFactory.CreateItem(fullType)

    if grid:canAddItem(item) then
        debugPrint("We can add the item")
    end

    inv:addItemOnServer(item)
    inv:AddItem(item)
    inv:setDrawDirty(true)
    inv:setHasBeenLooted(true)

    grid:insertItem(item, x, y, 1, isRotated)

    ISInventoryPage.renderDirty = true

end

--* Client Only

---@diagnostic disable: lowercase-global
function printPlayerModData()
    local md = PZEFT_UTILS.GetPlayerModData()
    PZEFT_UTILS.PrintTable(md)
end

local function LoopHighlightExtractionPoints()
    local instance = getPlayer():getModData().currentInstance
    local extractionPoints = instance.extractionPoints
    local hc = getCore():getBadHighlitedColor()

    for i = 1, #extractionPoints do
        local singleExtractionPoint = extractionPoints[i]
        local x1 = instance.x + singleExtractionPoint.x1
        local y1 = instance.y + singleExtractionPoint.y1

        local x2 = instance.x + singleExtractionPoint.x2
        local y2 = instance.y + singleExtractionPoint.y2

        local cell = getCell()
        local sq1 = cell:getGridSquare(x1,y1,0)

        if sq1 then
            sq1:getFloor():setHighlightColor(hc)
            sq1:getFloor():setHighlighted(true)
        end

        local sq2 = cell:getGridSquare(x2,y2,0)

        if sq2 then
            sq2:getFloor():setHighlightColor(hc)
            sq2:getFloor():setHighlighted(true)
        end

    end
end

function HighlightExtractionPoints()
    Events.OnTick.Add(LoopHighlightExtractionPoints)
end



ServerData_client_debug = ServerData_client_debug or {}

-- PVP Instance Handling --

function ServerData_client_debug.loadNewInstances()
    sendClientCommand("SERVER_DEBUG", "loadNewInstances", {})
end

-- Print Data To Server Console --

function ServerData_client_debug.print_pvp_instances()
    sendClientCommand("SERVER_DEBUG", "print_pvp_instances", {})
end

function ServerData_client_debug.print_pvp_usedinstances()
    sendClientCommand("SERVER_DEBUG", "print_pvp_usedinstances", {})
end

function ServerData_client_debug.print_pvp_currentinstance()
    sendClientCommand("SERVER_DEBUG", "print_pvp_currentinstance", {})
end

function ServerData_client_debug.print_safehouses()
    sendClientCommand("SERVER_DEBUG", "print_safehouses", {})
end

function ServerData_client_debug.print_assignedsafehouses()
    sendClientCommand("SERVER_DEBUG", "print_assignedsafehouses", {})
end

function ServerData_client_debug.print_bankaccounts()
    sendClientCommand("SERVER_DEBUG", "print_bankaccounts", {})
end

function ServerData_client_debug.print_shopitems()
    sendClientCommand("SERVER_DEBUG", "print_shopitems", {})
end

function ServerData_client_debug.loadShopPrices()
    -- !!! THIS IS TO LET THE SERVER GENERATE THE SHOP ITEMS AND TRANSMIT THEM !!!
    sendClientCommand("SERVER_DEBUG", "loadShopPrices", {})
end


function ServerData_client_debug.calculateCratesValue()
    sendClientCommand("SERVER_DEBUG", "calculateCratesValue", {})

end

-- function ServerData_client_debug.transmit_shop_prices()
--     sendClientCommand("SERVER_DEBUG")
-- end

-- Match Handling --

function ServerData_client_debug.getNextInstance()
    sendClientCommand("SERVER_DEBUG", "getNextInstance", {})
end

function ServerData_client_debug.TeleportPlayersToInstance()
    sendClientCommand("SERVER_DEBUG", "TeleportPlayersToInstance", {})
end

function ServerData_client_debug.sendPlayersToSafehouse()
    sendClientCommand("SERVER_DEBUG", "sendPlayersToSafehouse", {})
end


-- Bank handling --

function ServerData_client_debug.setBankAccount(name, balance)
    sendClientCommand(EFT_MODULES.Bank, "ProcessTransaction", {amount = 100000000})
    --sendClientCommand("SERVER_DEBUG", "setBankAccount", {name = name, balance = balance} )
end
