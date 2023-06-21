local ServerCommands = {}

ServerCommands.ReceiveTimeUpdate = function(time)
    print("Server Command - ReceiveTimeUpdate")
    print(time[1])

    -- TODO Latency tests
end

---------------------

local OnServerCommand = function(module, command, args)
    if module == 'PZEFT-Time' and ServerCommands[command] then
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)