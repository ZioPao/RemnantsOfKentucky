
------------------------------------------------------------------------
--* COMMANDS FROM CLIENTS *--
------------------------------------------------------------------------

local TimeCommands = {}
local MODULE = EFT_MODULES.UI

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