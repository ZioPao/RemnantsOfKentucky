if isServer() then
    Events.OnServerStarted.Add(function()
        pcall(function()
            if deleteInstancesROK then
                debugPrint("Deleting maps data on start")
                --local path = "Multiplayer\\" .. getServerName()

                local startX = 0
                local startY = 0

                local endX = 600
                local endY = 100

                deleteInstancesROK(startX, startY, endX, endY) -- Java mod necessary for this to work

                -- Reset Used Instances in ModData
                local PvpInstanceManager = require("ROK/PvpInstanceManager")
                PvpInstanceManager.Reset()
            else
                debugPrint("JAVA MOD NOT FOUND! PVP INSTANCES DATA WON'T BE RESET")
            end
        end)
    end)
end

-- TODO Trigger restart when instances are all used up