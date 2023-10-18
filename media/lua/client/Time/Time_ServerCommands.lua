local ServerCommands = {}

ServerCommands.OpenTimePanel = function()
    TimePanel.Open()
end


ServerCommands.ReceiveTimeUpdate = function(time)
    --print("Server Command - ReceiveTimeUpdate")
    --print(time[1])
    ClientState.currentTime = time[1]
    -- Locally, 1 player, about 4-5 ms of delay.
end

---------------------

local OnServerCommand = function(module, command, args)

    if module ~= 'PZEFT-Time' then return end

    --debugPrint("On Server Command - PZEFT-Time")
    if ServerCommands[command] then
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)