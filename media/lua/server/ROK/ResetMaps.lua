Events.OnServerStarted.Add(function()
    pcall(function()
        debugPrint("Deleting maps data on start")
        local path = "Multiplayer\\" .. getServerName()
        deleteInstancesEFT(path) -- Java mod necessary for this to work
    end)
end)