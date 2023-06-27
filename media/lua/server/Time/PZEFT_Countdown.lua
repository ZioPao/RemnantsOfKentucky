--[[⠀
Based on lua_timers by Vyshnia!
Permissions granted by original author

Original mod details:
Workshop ID: 2875394066
Mod ID: LuaTimers
--]]

local os_time = os.time
local EFT_Countdown = {}

function EFT_Countdown.Update()
	local currTime = os_time()
	--print(currTime)
	local currSeconds = EFT_Countdown.stopTime - currTime
	--print(currSeconds)

	-- TODO THIS IS JUST FOR DEBUG

	if not isServer() then
		sendServerCommand(getPlayer(), "PZEFT-Time", "ReceiveTimeUpdate", {currSeconds})

	else
		sendServerCommand("PZEFT-Time", "ReceiveTimeUpdate", {currSeconds})

	end

	if currTime >= EFT_Countdown.stopTime then
		print("STOP COUNTDOWN! Running func!")
		EFT_Countdown.func()
		Events.OnTickEvenPaused.Remove(EFT_Countdown.Update)
	end
end

function EFT_Countdown.Setup(stopTime, func)
	-- Will run the func after the end
	EFT_Countdown.func = func
	EFT_Countdown.stopTime = os_time() + stopTime

	Events.OnTickEvenPaused.Add(EFT_Countdown.Update)

end

return EFT_Countdown
