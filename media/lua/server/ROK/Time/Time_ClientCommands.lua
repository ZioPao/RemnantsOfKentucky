local Countdown = require("ROK/Time/Countdown")
local MatchHandler = require("ROK/MatchController")
-------------------

local ClientCommands = {}
local MODULE = EFT_MODULES.Time

---@param playerObj IsoPlayer
---@param args {stopTime : number}
function ClientCommands.StartMatchCountdown(playerObj, args)
    local function StartMatch()
        debugPrint("Start Match")
        local handler = MatchHandler:new()
        handler:initialise()
        handler:waitForStart()

        -- Closes automatically the admin panel\switch it to the during match one
        sendServerCommand(playerObj, EFT_MODULES.UI, 'SwitchMatchAdminUI', {startingState='BEFORE'})
    end

    -- TODO Can't load getText from here for some reason. Workaround
    local matchStartingText = "The match is starting"
    Countdown.Setup(args.stopTime, StartMatch, true, matchStartingText)
end

function ClientCommands.StopMatchCountdown()
    Countdown.Stop()
end

---@param playerObj IsoPlayer
---@param args {stopTime : number}
function ClientCommands.StartMatchEndCountdown(playerObj, args)

    local function StopMatch()
        local handler = MatchHandler.GetHandler()
        if handler then handler:stopMatch() end

        sendServerCommand(playerObj, EFT_MODULES.UI, 'SwitchMatchAdminUI', {startingState='DURING'})
    end

    local text = "The match has ended"
    Countdown.Setup(args.stopTime, StopMatch, true, text)
    --sendServerCommand(EFT_MODULES.UI, 'SetTimePanelDescription', {index = 2})       -- 2 = The match has ended
end

---* Setting time from client
function ClientCommands.SetDayTime()
    debugPrint("Setting time to 9")
    getGameTime():setTimeOfDay(9)
end

function ClientCommands.SetNightTime()
    debugPrint("Setting time to 23")
    getGameTime():setTimeOfDay(23)
end



-----------------------------

local OnClientCommand = function(module, command, playerObj, args)
    if module == MODULE and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)