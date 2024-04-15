Events.OnServerStarted.Add(function()
    pcall(function()
        if deleteInstancesEFT then
            debugPrint("Deleting maps data on start")
            local path = "Multiplayer\\" .. getServerName()
            deleteInstancesEFT(path) -- Java mod necessary for this to work

            -- Reset Used Instances in ModData
            local PvpInstanceManager = require("ROK/PvpInstanceManager")
            PvpInstanceManager.Reset()
        else
            debugPrint("JAVA MOD NOT FOUND! PVP INSTANCES DATA WON'T BE RESET")
        end
    end)
end)