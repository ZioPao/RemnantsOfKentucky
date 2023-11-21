---@diagnostic disable: lowercase-global
require("ROK/Config")
--- DEBUG
--- Gets player position and copies coordinates to clipboard

-- local oldSendServerCommand = sendServerCommand
-- ---Override for singleplayer testing
-- function sendServerCommand(playerObj, module, command, args)
--     if (not isClient() and not isServer()) then --if SP
--         triggerEvent("OnServerCommand", module, command, args);
--     else --if MP
--         print("Server: oldSendServerCommand")
--         oldSendServerCommand(playerObj, module, command, args)
--     end
-- end

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
