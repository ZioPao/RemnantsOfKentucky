local ServerCommands = {}

ServerCommands.ReceiveTimeUpdate = function(time)
    -- TODO Should we make separate functions for a timer and a countdown?
    print("Server Command - ReceiveTimeUpdate")
    print(time[1])
end

---------------------

local OnServerCommand = function(module, command, args)
    if module == 'PZEFT-Time' and ServerCommands[command] then
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)