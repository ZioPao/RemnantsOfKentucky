-- -- Should be triggered only when in a safehouse, never elsewhere
-- local SafehouseInstanceHandler = require("ROK/SafehouseInstanceHandler")
-- -- FIXME This would work only on admins, not normal players. Rethink this
-- local function DespawnZombies(zombie)
--     -- Double check, player need to be in their safehouse
--     --if not SafehouseInstanceHandler.IsInSafehouse() then return end
--     debugPrint("Removing zombies")

--     --SendCommandToServer(string.format("/removezombies -remove true"))
--     if zombie and instanceof(zombie, "IsoZombie") then
-- 		zombie:removeFromWorld()
-- 		zombie:removeFromSquare()

--         EFTRemoveZombie(zombie)
-- 	end
-- end

-- Events.OnZombieUpdate.Add(DespawnZombies)


-- -- local function StartZombieDespawner()
-- --     debugPrint("Activating zombie despawner")
-- --     Events.OnZombieUpdate.Remove(DespawnZombies)
-- --     Events.OnZombieUpdate.Add(DespawnZombies)
-- -- end
-- -- local function StopZombieDespawner()
-- --     debugPrint("Deactivating zombie despawner")
-- --     Events.OnZombieUpdate.Remove(DespawnZombies)

-- -- end


-- -- Events.PZEFT_OnMatchStart.Add(StopZombieDespawner)
-- -- Events.OnPlayerDeath.Add(StopZombieDespawner)
-- -- Events.PZEFT_OnMatchEnd.Add(StartZombieDespawner)
-- -- Events.OnZombieUpdate.Add(DespawnZombies)


-- -- Events.PZEFT_OnSuccessfulTeleport.Add(function()
-- --     debugPrint("Teleported, despawning zombies near player")        -- TODO Probably still a bit too early to work correctly
-- --     -- TODO Add delay func
-- --     --SendCommandToServer(string.format("/removezombies -remove true"))
-- -- end)