---@diagnostic disable: lowercase-global
require("ROK/Config")

function debugPrint(text)
    if PZ_EFT_CONFIG.Debug then
        print("PZEFT: " .. tostring(text))
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
    print(s)
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


if not isClient() then return end

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
    sendClientCommand("SERVER_DEBUG", "setBankAccount", {name = name, balance = balance} )
end
