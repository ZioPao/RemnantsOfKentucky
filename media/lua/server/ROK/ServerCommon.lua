-- local Countdown = require("ROK/Countdown")
-- ---------------

-- ---@class ServerCommon
-- local ServerCommon = {}

-- ServerCommon.isActive = false




-- ---------------

-- Events.OnConnected.Add(function()

--     if ServerCommon.isActive == false then
--         ServerCommon.isActive = true


--         -- Reactive auto-countdown if it was active
--         if MatchController.isAutomaticStart then
--             MatchController.AutoStartMatch()
--         end

--     end

-- end)

-- Events.OnDisconnect.Add(function()
--     local onlinePlayers = getOnlinePlayers()

--     if onlinePlayers == 0 then
--         debugPrint("Stopping countdowns")
--         Countdown.Stop()
--         --ServerCommon.isActive = false
--     end
-- end)


------------------------------------------------------------------------
--* COMMANDS FROM CLIENTS *--
------------------------------------------------------------------------

local TimeCommands = {}
local MODULE = EFT_MODULES.Time

---* Setting time from client
function TimeCommands.SetDayTime()
    debugPrint("Setting time to 9")
    getGameTime():setTimeOfDay(9)
end

function TimeCommands.SetNightTime()
    debugPrint("Setting time to 23")
    getGameTime():setTimeOfDay(23)
end


-----------------------------
local function OnTimeCommand(module, command, playerObj, args)
    if module == MODULE and TimeCommands[command] then
        TimeCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnTimeCommand)





