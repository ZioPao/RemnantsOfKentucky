-- Should be triggered only when in a safehouse, never elsewhere

local function DespawnZombies(zombie)
    local id = zombie:getOnlineID()
    debugPrint("Found a zombie in a safehouse! id = " .. tostring(id))
    --sendClientCommand(EFT_MODULES.Safehouse, "DespawnZombies", { id = id })
    zombie:removeFromWorld()
    zombie:removeFromSquare()
end

local function StartZombieDespawner()
    debugPrint("Activating zombie despawner")
    Events.OnZombieUpdate.Remove(DespawnZombies)
    Events.OnZombieUpdate.Add(DespawnZombies)
end
local function StopZombieDespawner()
    debugPrint("Deactivating zombie despawner")
    Events.OnZombieUpdate.Remove(DespawnZombies)

end


Events.PZEFT_OnMatchStart.Add(StopZombieDespawner)
Events.PZEFT_OnMatchEnd.Add(StartZombieDespawner)
Events.OnZombieUpdate.Add(DespawnZombies)
