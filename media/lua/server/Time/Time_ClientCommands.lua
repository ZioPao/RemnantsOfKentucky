local ClientCommands = {}

local Countdown = require("Time/EFT_Countdown")
local Timer = require("Time/EFT_Timer")


local function test()
    print("Done!")
end

ClientCommands.StartCountdown = function(_, args)
    print("PZFET-Time: countdown setup")
    print(args.stopTime)

    Countdown.Setup(args.stopTime, test)
end

ClientCommands.StartTimer = function(_, args)
    print("PZFET-Time: timer setup")
    print(args.stopTime)

    Timer.Setup(args.stopTime, args.timeBetweenFunc, test)
end

-----------------------------

local OnClientCommand = function(module, command, playerObj, args)
    if module == 'PZEFT-Time' and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)