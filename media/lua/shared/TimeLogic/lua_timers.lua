--[[⠀
Glytch3r:
This Lua file is from an api mod by Vishnya
I added this file(with permission) to reduce dependencies

original mod details:
Workshop ID: 2875394066
Mod ID: LuaTimers
--]]

local os_time = os.time
local table_insert = table.insert
local table_remove = table.remove
local assert = assert
local type = type
local pairs = pairs



local EFT_Timer = {
	Timers = {},
	SimpleTimers = {}
}


-- TODO We should change its name to prevent issues with other mods that use lua_timers

function EFT_Timer:Simple(delay, func, isCountdown)

	assert(type(delay) == "number", "Delay of timer should be a number type")
	assert(type(func) == "function", "Func of timer should be a function type (lol)")

	table_insert(self.SimpleTimers, {
		StartTime = os_time(),
		EndTime = os_time() + delay,
		Func = func,
		IsCountdown = isCountdown
	})

end

function EFT_Timer:Create(name, delay, repetitions, func, isCountdown)
	
	assert(type(name) == "string", "ID of timer should be a string type")
	assert(type(delay) == "number", "Delay of timer should be a number type")
	assert(type(repetitions) == "number", "Repetitions of timer should be a number type")
	assert(type(func) == "function", "Func of timer should be a function type (lol)")
	
	self.Timers[name] = {
		Delay = delay,
		StartRepetitions = repetitions,
		Repetitions = repetitions,
		LastFuncTime = os_time(),
		Func = func,
		Paused = false,
	}

end

local function timerUpdate()

	local cur_time = os_time()

	for k,v in pairs(EFT_Timer.Timers) do

		if not v.Paused then
			
			if cur_time >= v.LastFuncTime + v.Delay then

				v.LastFuncTime = cur_time

				v.Repetitions = v.Repetitions - 1

				v.Func()

				if v.Repetitions <= 0 then

					timer.Timers[k] = nil

				end

			end

		end

	end

	local simple_timers = EFT_Timer.SimpleTimers

	for i = #simple_timers, 1, -1 do

		local t = simple_timers[i]

	-- TODO TEST STUFF


		if t.StartTime then
			if t.IsCountdown then
				print(t.EndTime - cur_time)
				sendServerCommand("PZEFT", "ReceiveTimeUpdate", t.EndTime - cur_time)

			else
				print(cur_time - t.StartTime)

			end
			
		end


		if t.EndTime <= cur_time then

			t.Func()
			table_remove(simple_timers, i)

		end

	end

end
Events.OnTickEvenPaused.Add(timerUpdate)
	
function EFT_Timer:Remove(name)

	local t = self.Timers[name]

	if not t then return false end

	self.Timers[name] = nil

	return true

end

function EFT_Timer:Exists(name)

	return self.Timers[name] and true or false

end

function EFT_Timer:Start(name)

	local t = self.Timers[name]

	if not t then return false end

	t.Repetitions = t.StartRepetitions
	t.LastFuncTime = os_time()
	t.Paused = false
	t.PausedTime = nil

	return true

end

function EFT_Timer:Pause(name)

	local t = self.Timers[name]

	if not t then return false end

	if t.Paused then return false end

	t.Paused = true
	t.PausedTime = os_time()

	return true

end

function EFT_Timer:UnPause(name)

	local t = self.Timers[name]

	if not t then return false end

	if not t.Paused then return false end

	t.Paused = false

	return true

end
EFT_Timer.Resume = EFT_Timer.UnPause

function EFT_Timer:Toggle(name)

	local t = self.Timers[name]

	if not t then return false end

	t.Paused = not t.Paused

	return true

end

function EFT_Timer:TimeLeft(name)

	local t = self.Timers[name]

	if not t then return end

	if t.Paused then

		return (t.Repetitions - 1) * t.Delay + (t.LastFuncTime + t.Delay - t.PausedTime)

	else

		return (t.Repetitions - 1) * t.Delay + (t.LastFuncTime + t.Delay - os_time())

	end

end

function EFT_Timer:NextTimeLeft(name)

	local t = self.Timers[name]

	if not t then return end

	if t.Paused then

		return t.LastFuncTime + t.Delay - t.PausedTime

	else

		return t.LastFuncTime + t.Delay - os_time()

	end

end

function EFT_Timer:RepsLeft(name)

	local t = self.Timers[name]

	return t and t.Repetitions

end

return EFT_Timer