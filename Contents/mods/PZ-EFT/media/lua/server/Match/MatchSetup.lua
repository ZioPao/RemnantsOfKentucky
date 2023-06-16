MatchSetup = MatchSetup or {}

--- Search in the pool of useable map and get a clean one
MatchSetup.FetchCleanInstance = function()

    -- TODO we need to get a 'clean' instance from the pool
    local x = 0
    local y = 0
    return x,y

end



---Start up a new match
MatchSetup.Start = function()

    local x,y = MatchSetup.FetchCleanInstance()


    ------------

    -- At this point we should the coordinates for the new instance. 
    -- So, we get some 'random' spawn points where we're gonna place the players

    local playersArray = getOnlinePlayers()

    -- Map is 2 cells x 3 cells, so we have
    -- 300 x 300 squares = 90.000 squares
    -- 90000 x 6 = 540.000

    for i=0, playersArray:size() do
        local randomX = ZombRand(x, x + 540000)
        local randomY = ZombRand(y, y + 540000)

        local pl = playersArray:get(i)
        PZEFT_UTILS.TeleportPlayer(pl, randomX, randomY, 0)

    end



    ---------------------------------
    -- TODO Init timer on screen


    ---------------------------------
    -- TODO Start zombie spawning logic



end
