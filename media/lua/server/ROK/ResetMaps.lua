if isServer() then
    local PvpInstanceManager = require("ROK/PvpInstanceManager")


    Events.OnServerStarted.Add(function()
        pcall(function()
            local amount = PvpInstanceManager.GetAmountAvailableInstances()

            if deleteInstancesROK then
                debugPrint("Deleting maps data on start")
                --local path = "Multiplayer\\" .. getServerName()

                local startX = 0
                local startY = 0

                local endX = 600
                local endY = 100

                deleteInstancesROK(startX, startY, endX, endY) -- Java mod necessary for this to work

                -- Reset Used Instances in ModData
                PvpInstanceManager.Reset()
            else
                debugPrint("JAVA MOD NOT FOUND! PVP INSTANCES DATA WON'T BE RESET")

                debugPrint("Current amount of used instances: " .. tostring(amount))
                if amount <= 0 then
                    debugPrint(
                    "You don't have any PVP instances left. Please follow the guide to reset PVP Instances Data")
                    getCore():quit()
                end
            end
        end)
    end)


    -- Stops server when instances are all used up

    Events.OnMatchEnd.Add(function()
        local amount = PvpInstanceManager.GetAmountAvailableInstances()
        debugPrint("Current amount of used instances: " .. tostring(amount))
        if amount <= 0 then
            debugPrint("No more instances left, saving and quitting")
            -- Based on UdderlyUpToDate
            Events.OnSave.Add(function()
                getCore():quit()
            end)
            saveGame()
        end
    end)
end
