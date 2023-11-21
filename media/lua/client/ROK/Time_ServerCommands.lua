local MODULE = EFT_MODULES.Time
----------------

local TimeCommands = {}

function TimeCommands.OpenTimePanel()
    TimePanel.Open()
end

---@param args {time : number}
function TimeCommands.ReceiveTimeUpdate(args)
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
local OnTimeCommand = function(module, command, args)

    if module ~= MODULE then return end

    --debugPrint("On Server Command - PZEFT-Time")
    if TimeCommands[command] then
        TimeCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnTimeCommand)