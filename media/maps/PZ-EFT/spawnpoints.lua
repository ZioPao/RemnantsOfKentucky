function SpawnPoints()
  return {
    constructionworker = {
      { worldX = 1, worldY = 1, posX = 97, posY = 26, posZ = 0 }
    },
    fireofficer = {
      { worldX = 1, worldY = 1, posX = 97, posY = 26, posZ = 0 }
    },
    parkranger = {
      { worldX = 1, worldY = 1, posX = 97, posY = 26, posZ = 0 }
    },
    policeofficer = {
      { worldX = 1, worldY = 1, posX = 97, posY = 26, posZ = 0 }
    },
    securityguard = {
      { worldX = 1, worldY = 1, posX = 97, posY = 26, posZ = 0 }
    },
    unemployed = {
      { worldX = 1, worldY = 1, posX = 97, posY = 26, posZ = 0 }
    }
  }
end

function SpawnRegions()
	return {
		-- { name = "Muldraugh, KY", file = "media/maps/Muldraugh, KY/spawnpoints.lua" },
		-- { name = "West Point, KY", file = "media/maps/West Point, KY/spawnpoints.lua" },
		-- { name = "Rosewood, KY", file = "media/maps/Rosewood, KY/spawnpoints.lua" },
		-- { name = "Riverside, KY", file = "media/maps/Riverside, KY/spawnpoints.lua" },

		{name = "Remnants of Kentucky", file = "media/maps/PZ-EFT/spawnpoints.lua"}
		-- Uncomment the line below to add a custom spawnpoint for this server.
--		{ name = "Twiggy's Bar", serverfile = "pandegehenna_spawnpoints.lua" },
	}
end
