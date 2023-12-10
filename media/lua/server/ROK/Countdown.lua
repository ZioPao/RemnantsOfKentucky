--[[⠀
Based on lua_timers by Vyshnia!
Permissions granted by the original author

Original mod details:
Workshop ID: 2875394066
Mod ID: LuaTimers
--]]

local os_time = os.time

---@class Countdown
---@field intervals {}
local Countdown = {}

---Will run the func after the end
---@param stopTime number
---@param fun function
---@param displayOnClient boolean?
---@param description string?
function Countdown.Setup(stopTime, fun, displayOnClient, description)
	Countdown.fun = fun

	if fun == nil then
		error("Function is nil!")
	end

	Countdown.stopTime = os_time() + stopTime


	if displayOnClient and displayOnClient == true then
		description = description or ""
		sendServerCommand(EFT_MODULES.Time, "OpenTimePanel", {description = description})
		Countdown.displayOnClient = true
	else
		Countdown.displayOnClient = false
	end

	Events.OnTickEvenPaused.Add(Countdown.Update)
end

---@param interval number in seconds
---@param fun function
function Countdown.AddIntervalFunc(interval, fun)

	local intTab = {
		counter = 0,
		base = interval,
		stopTime = os_time() + interval,
		fun = fun
	}

	if Countdown.intervals == nil then
		Countdown.intervals = {}
	end
	table.insert(Countdown.intervals, intTab)
end

function Countdown.Update()
	-- This can throw an error when we use Stop. It's only on the server and it shouldn't really matter though
	local currTime = os_time()
	local currSeconds = Countdown.stopTime - currTime

	if Countdown.displayOnClient and Countdown.displayOnClient == true then
		sendServerCommand(EFT_MODULES.Time, "ReceiveTimeUpdate", { time = currSeconds })
	end

	-- Check interval funcs
	if Countdown.intervals then
		for i=1, #Countdown.intervals do
			local intTab = Countdown.intervals[i]
			if currTime >= intTab.stopTime then
				intTab.counter = intTab.counter + 1
				intTab.stopTime = os_time() + intTab.base	-- Updates it for the next iteration
				--debugPrint("Running interval function -> " .. tostring(intTab.fun))
				intTab.fun(intTab.counter)
			end
		end
	end

	if currTime >= Countdown.stopTime then
		Events.OnTickEvenPaused.Remove(Countdown.Update)
		debugPrint("STOP COUNTDOWN! Running func!")
		Countdown.fun()
	end
end

---Stop the countdown
function Countdown.Stop()

	Countdown.stopTime = -1		-- use -1 to prevent issues when looping
	Countdown.fun = nil
	Countdown.intervals = {}

	if Countdown.displayOnClient and Countdown.displayOnClient == true then
		-- Close forcefully TimePanel on the clients
		sendServerCommand(EFT_MODULES.Time, "ReceiveTimeUpdate", { time = 0 })
	end

	Events.OnTickEvenPaused.Remove(Countdown.Update)
end


------------------------------------------------------------------------
--* COMMANDS FROM CLIENTS *--
------------------------------------------------------------------------

local MatchHandler = require("ROK/MatchController")
-------------------

local CountdownCommands = {}
local MODULE = EFT_MODULES.Time

---@param playerObj IsoPlayer
---@param args {stopTime : number}
function CountdownCommands.StartMatchCountdown(playerObj, args)
    local function StartMatch()
        debugPrint("Start Match")
        local handler = MatchHandler:new()
        handler:initialise()
        handler:waitForStart()

        -- Closes automatically the admin panel\switch it to the during match one
        sendServerCommand(playerObj, EFT_MODULES.UI, 'SwitchMatchAdminUI', {startingState='BEFORE'})
    end

    -- TODO Can't load getText from here for some reason. Workaround
    local matchStartingText = "The match is starting"
    Countdown.Setup(args.stopTime, StartMatch, true, matchStartingText)
end

function CountdownCommands.StopMatchCountdown()
    Countdown.Stop()
end

---@param playerObj IsoPlayer
---@param args {stopTime : number}
function CountdownCommands.StartMatchEndCountdown(playerObj, args)

    local function StopMatch()
        local handler = MatchHandler.GetHandler()
        if handler then handler:stopMatch() end

        sendServerCommand(playerObj, EFT_MODULES.UI, 'SwitchMatchAdminUI', {startingState='DURING'})
    end

    local text = "The match has ended"
    Countdown.Setup(args.stopTime, StopMatch, true, text)
    --sendServerCommand(EFT_MODULES.UI, 'SetTimePanelDescription', {index = 2})       -- 2 = The match has ended
end

---* Setting time from client
function CountdownCommands.SetDayTime()
    debugPrint("Setting time to 9")
    getGameTime():setTimeOfDay(9)
end

function CountdownCommands.SetNightTime()
    debugPrint("Setting time to 23")
    getGameTime():setTimeOfDay(23)
end


-----------------------------
local function OnCountdownCommand(module, command, playerObj, args)
    if module == MODULE and CountdownCommands[command] then
        CountdownCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnCountdownCommand)


return Countdown
