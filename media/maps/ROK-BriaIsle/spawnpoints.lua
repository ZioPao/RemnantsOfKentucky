function SpawnPoints()

  --todo REMOVE the main map from .ini


  local spawns = {
      { worldX = 0, worldY = 100, posX = 10, posY = 10, posZ = 0 },
  }
  return {
      chef = spawns,
      constructionworker = spawns,
      doctor = spawns,
      fireofficer = spawns,
      parkranger = spawns,
      policeofficer = spawns,
      repairman = spawns,
      securityguard = spawns,
      unemployed = spawns,


      -- Custom professions
      SharpShooter = spawns,
      Brawler = spawns,
      Medic = spawns,
      Scavenger = spawns
  }
end