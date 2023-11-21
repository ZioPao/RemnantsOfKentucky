--[[⠀
Based on lua_timers by Vyshnia!
Permissions granted by the original author

Original mod details:
Workshop ID: 2875394066
Mod ID: LuaTimers
--]]

local os_time = os.time
local Countdown = {}

---Will run the func after the end
---@param stopTime number
---@param fun function
function Countdown.Setup(stopTime, fun)
	Countdown.fun = fun

	if fun == nil then
		error("Function is nil!")
	end

	Countdown.stopTime = os_time() + stopTime

	Events.OnTickEvenPaused.Add(Countdown.Update)
end

---comment
---@param interval number in seconds
---@param fun function
function Countdown.AddIntervalFunc(interval, fun)

	Countdown.interval = {
		counter = 0,
		base = interval,
		stopTime = os_time() + interval,
		fun = fun
	}
end

function Countdown.Update()
	local currTime = os_time()
	local currSeconds = Countdown.stopTime - currTime

	-- TODO THIS IS JUST FOR DEBUG
	if not isServer() then
		sendServerCommand(getPlayer(), EFT_MODULES.Time, "ReceiveTimeUpdate", { time = currSeconds })
	else
		sendServerCommand(EFT_MODULES.Time, "ReceiveTimeUpdate", { time = currSeconds })
	end

	-- Check interval fun
	if Countdown.interval then
		if currTime >= Countdown.interval.stopTime then
			Countdown.interval.counter = Countdown.interval.counter + 1
			Countdown.interval.stopTime = os_time() + Countdown.interval.base	-- Updates it for the next iteration
			debugPrint("Running interval function")
			Countdown.interval.fun(Countdown.interval.counter)
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

	Countdown.stopTime = nil
	Countdown.fun = nil

	Countdown.interval = nil


	Events.OnTickEvenPaused.Remove(Countdown.Update)
end

return Countdown
