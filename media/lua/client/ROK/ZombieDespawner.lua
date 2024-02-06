local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")

local function DespawnZombies(zombie)
    --if not SafehouseInstanceHandler.IsInSafehouse() then return end

    local onlineID = zombie:getOnlineID()
    debugPrint("NoZombiesAllowed: Sending removeZombie ID: " .. onlineID)
    sendClientCommand(EFT_MODULES.Match, "KillZombies", { id = onlineID })
    zombie:removeFromWorld()
    zombie:removeFromSquare()
end

function ActivateZombieDespawner()
    Events.OnZombieUpdate.Remove(DespawnZombies)
    Events.OnZombieUpdate.Add(DespawnZombies)
end

function DeactivateZombieDespawner()
    Events.OnZombieUpdate.Remove(DespawnZombies)
end


--* Activate it at startup
Events.OnGameStart.Add(ActivateZombieDespawner)
Events.PZEFT_OnMatchEnd.Add(ActivateZombieDespawner)
Events.PZEFT_OnSuccessfulTeleport.Add(function()
    debugPrint("Teleported, despawning zombies near player")
    ActivateZombieDespawner()
    local Delay = require("ROK/Delay")
    Delay:set(2, function()
        debugPrint("Deactivating zombie despawner")
        DeactivateZombieDespawner()
    end)
end)

Events.PZEFT_OnMatchStart.Add(DeactivateZombieDespawner)
Events.OnPlayerDeath.Add(DeactivateZombieDespawner)

