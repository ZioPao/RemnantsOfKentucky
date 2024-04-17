if isServer() then
    local function ResetMaps()
        debugPrint("Running OnServerStarted ResetMaps function")

        local PvpInstanceManager = require("ROK/PvpInstanceManager")
        local amount = PvpInstanceManager.GetAmountAvailableInstances()

        if deleteInstancesROK then
            debugPrint("Deleting maps data on start")
            --local path = "Multiplayer\\" .. getServerName()

            local startX = 0
            local startY = 0

            local endX = 600
            local endY = 100

            deleteInstancesROK(startX, startY, endX, endY)     -- Java mod necessary for this to work

            -- Reset Used Instances in ModData
            PvpInstanceManager.Reset()
        else
            debugPrint("JAVA MOD NOT FOUND! PVP INSTANCES DATA WON'T BE RESET")

            debugPrint("Current amount of available instances: " .. tostring(amount))
            if amount <= 0 then
                debugPrint(
                    "You don't have any PVP instances left. Please follow the guide to reset PVP Instances Data")
                getCore():quit()
            end
        end
    end

    Events.OnServerStarted.Add(function()
        pcall(ResetMaps)
    end)

    local function Quit()
        getCore():quit()

    end
    -- Stops server when instances are all used up
    Events.PZEFT_OnMatchEnd.Add(function()
        local PvpInstanceManager = require("ROK/PvpInstanceManager")
        local amount = PvpInstanceManager.GetAmountAvailableInstances()
        debugPrint("Current amount of available instances: " .. tostring(amount))
        if amount <= 0 then
            debugPrint("No more instances left, saving and quitting")
            -- Based on UdderlyUpToDate
            Events.OnSave.Add(function()

                -- Timer, since Zomboid is a huge piece of shit (again) OnSave is triggered BEFORE we start saving data
                -- and OnPostSave doesn't get triggered (works only when quitting in specific circumstances). 
                -- We need an added delay to be sure that the game actually saved everything

                -- Kick everyone out to preserve their data
                local onlinePlayers = getOnlinePlayers()

                for i = 0, onlinePlayers:size() - 1 do
                    ---@type IsoPlayer
                    local player = onlinePlayers:get(i)
                    sendServerCommand(player, EFT_MODULES.State, "ForceQuit", {})
                end

                local shutdownDelay = 10
                debugPrint("Closing server in " .. tostring(shutdownDelay) .. " seconds")

                local Delay = require("ROK/Delay")
                Delay:set(shutdownDelay, Quit, "QuitServer")
            end)
            saveGame()
        end
    end)
end
