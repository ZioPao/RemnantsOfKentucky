-- Should be triggered only when in a safehouse, never elsewhere
local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")

local function DespawnZombies(zombie)
    -- Double check, player need to be in their safehouse
    if not SafehouseInstanceHandler.IsInSafehouse() then return end
	SendCommandToServer(string.format("/removezombies -remove true"))

    -- local id = zombie:getOnlineID()
    -- --debugPrint("Found a zombie in a safehouse! id = " .. tostring(id))
    -- --sendClientCommand(EFT_MODULES.Safehouse, "DespawnZombies", { id = id })
    -- zombie:removeFromWorld()
    -- zombie:removeFromSquare()
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
