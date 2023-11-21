local Countdown = require("ROK/Time/Countdown")
local MatchHandler = require("ROK/MatchController")
-------------------

local ClientCommands = {}
local MODULE = EFT_MODULES.Time

---@param playerObj IsoPlayer
---@param args {stopTime : number}
function ClientCommands.StartMatchCountdown(playerObj, args)
    local function StartMatch()
        debugPrint("Start Match")
        local handler = MatchHandler:new()
        handler:initialise()

        -- Closes automatically the admin panel\switch it to the during match one
        sendServerCommand(playerObj, EFT_MODULES.UI, 'SwitchMatchAdminUI', {startingState='BEFORE'})
    end
    Countdown.Setup(args.stopTime, StartMatch)
end

function ClientCommands.StopMatchCountdown()
    Countdown.Stop()
end

---@param playerObj IsoPlayer
---@param args {stopTime : number}
function ClientCommands.StartMatchEndCountdown(playerObj, args)

    local function StopMatch()
        local handler = MatchHandler.GetHandler()
        if handler then handler:stopMatch() end

        sendServerCommand(playerObj, EFT_MODULES.UI, 'SwitchMatchAdminUI', {startingState='DURING'})
    end

    Countdown.Setup(args.stopTime, StopMatch)
    sendServerCommand(EFT_MODULES.UI, 'SetTimePanelDescription', {index = 2})       -- 2 = The match has ended

end

-----------------------------

local OnClientCommand = function(module, command, playerObj, args)
    if module == MODULE and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)