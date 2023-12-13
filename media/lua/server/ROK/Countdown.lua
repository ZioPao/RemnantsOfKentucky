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

return Countdown