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

    local tagCosts = {
        FOOD = {name = "FOOD", priceMin = 100, priceMax = 200},
        CLOTHING_NORMAL = {name = "CLOTHING_NORMAL", priceMin = 50, priceMax = 400 },          -- No bullet defense
        CLOTHING_BAG = {name = "CLOTHING_BAG", priceMin = 200, priceMax = 2000},
        CLOTHING_MILITARY = {name = "CLOTHING_MILITARY", priceMin = 400, priceMax = 3500 },
        TOOL = {name = "TOOL", priceMin = 100, priceMax = 1500 },            -- Only tool, like a saw
        TOOL_MELEE = {name = "TOOL_MELEE", priceMin = 500, priceMax = 2500 },
        GUN = {name = "GUN", priceMin = 300, priceMax = 5000},
        GUN_PART = {name = "GUN_PART", priceMin = 150, priceMax = 1000},
        COSMETIC = {name = "COSMETIC", priceMin = 100, priceMax = 10000},
        EXP = {name = "EXP", priceMin = 1000, priceMax = 10000}
    }

    for i=0, allItems:size() - 1 do

        ---@type Item
        local item = allItems:get(i)

        if not item:isHidden() then


            local fullType = item:getModuleName() .. "." .. item:getName()
            local itemType = item:getType()

            if itemType ~= Type.Key and itemType ~= Type.Map then
                local tag

                if itemType == Type.Clothing then
                    ---@type Clothing
                    local cItem = InventoryItemFactory.CreateItem(fullType)

                    if cItem:getBulletDefense() > 30 then
                        tag = tagCosts.CLOTHING_MILITARY
                    else
                        tag = tagCosts.CLOTHING_NORMAL
                    end
                elseif itemType == Type.Food then tag = tagCosts.FOOD
                elseif itemType == Type.Weapon then tag = tagCosts.GUN
                elseif itemType == Type.WeaponPart then tag = tagCosts.GUN_PART
                elseif itemType == Type.Literature then tag = tagCosts.EXP -- TODO Not 100% correct
                elseif itemType == Type.Radio or itemType == Type.AlarmClock or itemType == Type.AlarmClockClothing or itemType == Type.Drainable then
                    tag = tagCosts.TOOL
                elseif itemType == Type.Normal or itemType == Type.Moveable then
                    tag = tagCosts.COSMETIC
                elseif itemType == Type.Container then
                    tag = tagCosts.CLOTHING_BAG
                else
                    debugPrint(itemType)
                    debugPrint(fullType)
                    debugPrint("__")
                end
                local price = ZombRand(tag.priceMin, tag.priceMax)
                print("fullType: " .. fullType .. ", basePrice: " .. tostring(price) .. ", tag: " .. tag.name)
                print("_______________")
            end
        end
    end
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
