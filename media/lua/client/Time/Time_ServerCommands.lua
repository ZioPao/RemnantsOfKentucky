local ServerCommands = {}

ServerCommands.ReceiveTimeUpdate = function(time)
    --print("Server Command - ReceiveTimeUpdate")
    print(time[1])
    -- TODO Latency tests
    -- Locally, 1 player, about 4-5 ms of delay.
end

---------------------

local OnServerCommand = function(module, command, args)
    if module == 'PZEFT-Time' and ServerCommands[command] then
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)