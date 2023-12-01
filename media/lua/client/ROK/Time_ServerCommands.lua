local ClientState = require("ROK/ClientState")
----------------

local MODULE = EFT_MODULES.Time
local TimeCommands = {}

---@param args {description : string}
function TimeCommands.OpenTimePanel(args)
    TimePanel.Close()
    TimePanel.Open(args.description)

    --TODO FIX THIS
    ClientState.currentTime = 100       -- Workaround to prevent the TimePanel from closing
end

---@param args {time : number }
function TimeCommands.ReceiveTimeUpdate(args)
    ClientState.currentTime = args.time
    -- Locally, 1 player, about 4-5 ms of delay.
end

---------------------
local OnTimeCommand = function(module, command, args)

    if module ~= MODULE then return end

    --debugPrint("Running OnTimeCommand " .. command)
    if TimeCommands[command] then
        TimeCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnTimeCommand)