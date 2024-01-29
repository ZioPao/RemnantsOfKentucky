-- Should be triggered only when in a safehouse, never elsewhere
local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")

local function DespawnZombies()
    -- Double check, player need to be in their safehouse
    debugPrint("Removing zombies")
    if not SafehouseInstanceHandler.IsInSafehouse() then return end
	SendCommandToServer(string.format("/removezombies -remove true"))
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
Events.OnPlayerDeath.Add(StopZombieDespawner)
Events.PZEFT_OnMatchEnd.Add(StartZombieDespawner)
Events.OnZombieUpdate.Add(DespawnZombies)


Events.PZEFT_OnSuccessfulTeleport.Add(DespawnZombies)