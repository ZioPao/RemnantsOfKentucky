-- Based on Konijima - Kill All Zombies mod.

local function DespawnZombies(zombie)
    -- In case the player has died and the match is still running, their body would despawn zombies without this check
    if getPlayer():isDead() then return end

    local onlineID = zombie:getOnlineID()
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
Events.PZEFT_OnPlayerInitDone.Add(ActivateZombieDespawner)
Events.PZEFT_ClientNotInRaidAnymore.Add(ActivateZombieDespawner)
Events.PZEFT_OnSuccessfulTeleport.Add(function()
    debugPrint("Teleported, despawning zombies near player for 5 seconds")
    ActivateZombieDespawner()
    local Delay = require("ROK/Delay")
    Delay:set(5, function()
        debugPrint("Deactivating zombie despawner")
        DeactivateZombieDespawner()
    end)
end)

Events.PZEFT_ClientNowInRaid.Add(DeactivateZombieDespawner)
Events.OnPlayerDeath.Add(DeactivateZombieDespawner)
