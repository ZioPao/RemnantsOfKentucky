require "PZ_EFT_config"
--- DEBUG
--- Gets player position and copies coordinates to clipboard

function debugPrint(text)
    if PZ_EFT_CONFIG.Debug then
        print(text)
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

function TestCountdown()
    sendClientCommand("PZEFT-Time", "StartCountdown", {stopTime = 30})
end

function TestTimer()
    sendClientCommand("PZEFT-Time", "StartTimer", {stopTime = 30, timeBetweenFunc=5})
end
