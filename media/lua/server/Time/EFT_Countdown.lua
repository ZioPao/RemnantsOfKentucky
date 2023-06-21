local os_time = os.time
local EFT_Countdown = {}

function EFT_Countdown.Update()
	local currTime = os_time()
	--print(currTime)
	local currSeconds = EFT_Countdown.stopTime - currTime
	print(currSeconds)
	sendServerCommand("PZEFT-Time", "ReceiveCountdownUpdate", {currSeconds})

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
