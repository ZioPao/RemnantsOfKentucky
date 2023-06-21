local ClientCommands = {}

ClientCommands.StartCountdown = function(_, delay)

    local function test()
        print("Done!")
    end
    --sendClientCommand(getPlayer(), "PZEFT-Timer", "StartCountdown", 30)

    local timer = require("TimeLogic/lua_timers")
    timer:Simple(delay, test, true)
end


local OnClientCommand = function(module, command, playerObj, args)
    if module == 'PZEFT-Timer' and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)