local MODULE = 'PZEFT-Time'

----------------

local ServerCommands = {}

ServerCommands.OpenTimePanel = function()
    TimePanel.Open()
end

---comment
---@param args {time : number}
ServerCommands.ReceiveTimeUpdate = function(args)
    --print("Server Command - ReceiveTimeUpdate")
    --print(time[1])
    ClientState.currentTime = args.time

    -- Check if the timer is visible.
    if not TimePanel.instance:getIsVisible() then -- TODO this is mostly a workaround for now.
        TimePanel.Close()
        TimePanel.Open()
    end


    -- Locally, 1 player, about 4-5 ms of delay.
end

---------------------

local OnServerCommand = function(module, command, args)

    if module ~= MODULE then return end

    --debugPrint("On Server Command - PZEFT-Time")
    if ServerCommands[command] then
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)