local ClientCommands = {}

local Countdown = require("Time/PZEFT_Countdown")
local Timer = require("Time/PZEFT_Timer")
local MatchHandler = require("MatchHandler/MatchHandler")


local function test()
    print("Done!")
end

ClientCommands.StartMatchCountdown = function(playerObj, args)
    local function StartMatch()
        print("Start Match")
        local handler = MatchHandler:new()
        handler:initialise()

        -- Closes automatically the admin panel\switch it to the during match one
        sendServerCommand(playerObj, 'PZEFT-UI', 'SwitchMatchAdminUI', {startingState='BEFORE'})
    end
    Countdown.Setup(args.stopTime, StartMatch)
end

ClientCommands.StopMatchCountdown = function (_, _)
    Countdown.Stop()
end

ClientCommands.StartMatchEndCountdown = function(playerObj, args)

    local function StopMatch()
        local handler = MatchHandler.GetHandler()
        if handler then handler:stopMatch() end

        sendServerCommand(playerObj, 'PZEFT-UI', 'SwitchMatchAdminUI', {startingState='DURING'})
    end

    Countdown.Setup(args.stopTime, StopMatch)
    sendServerCommand('PZEFT-UI', 'SetTimePanelDescription', {index = 2})       -- 2 = The match has ended

end

ClientCommands.StartTimer = function(_, args)
    --print("PZFET-Time: timer setup")
    Timer.Setup(args.stopTime, args.timeBetweenFunc, test)
end

-----------------------------

local OnClientCommand = function(module, command, playerObj, args)
    if module == 'PZEFT-Time' and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)