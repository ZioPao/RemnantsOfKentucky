local os_time = os.time
local EFT_Timer = {}

function EFT_Timer.Update()
	local currTime = os_time()

	local currSeconds = currTime - EFT_Timer.startTime
	print(currSeconds)
	--print(EFT_Timer.stopTime)

	if currSeconds >= EFT_Timer.lastFuncTime + EFT_Timer.timeBetweenFunc then
		EFT_Timer.func()
		EFT_Timer.lastFuncTime = currTime - EFT_Timer.startTime
	end

	if currSeconds >= EFT_Timer.stopTime then
		Events.OnTickEvenPaused.Remove(EFT_Timer.Update)
	end
end

function EFT_Timer.Setup(stopTime, timeBetweenFunc, func)

	EFT_Timer.startTime = os_time()

	EFT_Timer.stopTime = stopTime

	EFT_Timer.timeBetweenFunc = timeBetweenFunc
	EFT_Timer.lastFuncTime = 0
	EFT_Timer.func = func

	Events.OnTickEvenPaused.Add(EFT_Timer.Update)
end

return EFT_Timer