Events.OnServerStarted.Add(function()
    pcall(function()
        debugPrint("Deleting maps data on start")
        local path = "Multiplayer\\" .. getServerName()
        deleteInstancesEFT(path) -- Java mod necessary for this to work

        -- Reset Used Instances in ModData
        local PvpInstanceManager = require("ROK/PvpInstanceManager")
        PvpInstanceManager.Reset()
    end)
end)