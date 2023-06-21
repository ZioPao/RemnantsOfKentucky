local ClientCommands = {}

local function test()
    print("Done!")
end

ClientCommands.StartCountdown = function(_, stopTime)
    EFT_Countdown.Setup(stopTime[1], test)
end

ClientCommands.StartTimer = function(_, stopTime)
    EFT_Timer.Setup(stopTime[1], 10, test)
end

local OnClientCommand = function(module, command, playerObj, args)
    if module == 'PZEFT-Time' and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)