---@class PZ_EFT_CONFIG
PZ_EFT_CONFIG = PZ_EFT_CONFIG or {}

PZ_EFT_CONFIG.Debug = true

PZ_EFT_CONFIG.SpawnCell = {
    x = 150,
    y = 150
}

--Cells containing safehouses for initialisation
PZ_EFT_CONFIG.SafehouseCells = {{
    x = 100,
    y = 100
},
{
    x = 100,
    y = 101
}}

--- For creating relative coordinates, no need to map coordinates or do manual math.
local relativeSafehouseEntrance = {
    x = 37,
    y = 29,
    z = 0
}

PZ_EFT_CONFIG.SafehouseInstanceSettings = {
    firstSafehouse = {
        relative = {
            x = relativeSafehouseEntrance.x,
            y = relativeSafehouseEntrance.y,
            z = relativeSafehouseEntrance.z
        }
    },
    safehouseGrid = {
        x = {
            count = 7,
            spacing = 40
        },
        y = {
            count = 7,
            spacing = 40
        }
    },
    -- Storage boxes will be placed always in the same point inside a safehouse.
    -- Relative position from the safehouse's spawn point
    storageRelativePosition = {
        x = 1,
        y = 1,
    },

    --- relative to entrance
    --- no building/disassembly
    safehouseStaticRoom = {
        x1 = 38 - relativeSafehouseEntrance.x,
        y1 = 25 - relativeSafehouseEntrance.y,
        x2 = 41 - relativeSafehouseEntrance.x,
        y2 = 21 - relativeSafehouseEntrance.y
    },

    --- relative to entrance
    --- for context menu check
    safehouseComputer = {
        x = 41 - relativeSafehouseEntrance.x,
        y = 24 - relativeSafehouseEntrance.y
    },
    
    --- relative to entrance
    --- for shop and wipe stuff
    safehouseStorage = {
        {x = 39 - relativeSafehouseEntrance.x, y = 21 - relativeSafehouseEntrance.y},
        {x = 40 - relativeSafehouseEntrance.x, y = 21 - relativeSafehouseEntrance.y},
        {x = 41 - relativeSafehouseEntrance.x, y = 21 - relativeSafehouseEntrance.y},
    },

    --- relative to entrance
    --- for building check
    safehouseEntranceNoBuildArea = {
        x1 = 37 - relativeSafehouseEntrance.x,
        y1 = 28 - relativeSafehouseEntrance.y,
        x2 = 41 - relativeSafehouseEntrance.x,
        y2 = 29 - relativeSafehouseEntrance.y
    },

    ---Dimensions of safehouse, relative to the entrance
    --- for is in safehouse check
    dimensions = {
        n = 9,
        s = 1,
        e = 4,
        w = 6
    },

    cratesAmount = 6
}

PZ_EFT_CONFIG.PVPInstanceSettings = {
    -- x length of map in cells
    xLength = 4,
    -- y length of map in cells
    yLength = 2,

    -- equal space between instances in all directions
    buffer = 1,

    -- first instance x cell position
    firstXCellPos = 0,
    -- first instance y cell position
    firstYCellPos = 0,

    -- how many times instances repeat in an x direction
    xRepeat = 10,
    -- how many times instances repeat in a y direction
    yRepeat = 10,

    -- -- number of random extraction points for each instance
    -- randomExtractionPointCount = 3      -- TODO Make it customizable or random
}



-- TODO Separate client from server only settings

--- STATIC ONLY SETTINGS!
PZ_EFT_CONFIG.MatchSettings = {
    -- Time related stuff, in seconds. Handled on the client
    startMatchTime = 5,     -- TODO 1 Minute
    loadWaitTime = 5,
    endMatchTime = 5,

    -- Server only
    roundTime = 1200,       -- 20 minutes
    roundOvertime = 300,    -- 5 minutes
    zombieIncreaseTime = 60,
    checkAlivePlayersTime = 10,      -- Every 10 seconds, we check if there are players alive in the match

    zombiesAmountBase = 2,          -- Base value for zombie spawn
    zombieSpawnMultiplier = 1,       -- 1, this could get really ugly.
    chanceRandomSoundOnZombieSpawn = 50

    -- As of now, zombies spawned should be around 600/700 in total per instance, at the highest.
}

PZ_EFT_CONFIG.Default = {
    balance = 10000,
    cratesValue = 0,
}


PZ_EFT_CONFIG.Shop = {
    dailyItemsAmount = 20,
    instaHealCost = 2500
}

------------------------------------------
---* Spawn points *-- 
-- World coordinates if PVP instance starts at cell 0,0

---@alias spawnPointsType {name : string, x : integer, y : integer, z : integer}

---@type table<integer, spawnPointsType> 
PZ_EFT_CONFIG.Spawnpoints = {}

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "SOUTHERN SHORE SPAWN #1",
    x = 525,
    y = 559,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "SOUTHERN SHORE SPAWN #2",
    x = 219,
    y = 540,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "SOUTHERN SHORE SPAWN #3",
    x = 34,
    y = 524,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "RADIO TOWER SPAWN",
    x = 715,
    y = 503,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "WESTERN SHORE SPAWN #1",
    x = 848,
    y = 445,
    z = 0
})

-- FIXME This spawnpoint is broken! 
-- table.insert(PZ_EFT_CONFIG.Spawnpoints, {
--     name = "WESTERN SHORE SPAWN #2",
--     x = 854,
--     y = 226,
--     z = 0
-- })

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "MEDICAL CENTER BATHROOMS SPAWN",
    x = 153,
    y = 425,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "EASTERN SHORE SPAWN #1",
    x = 29,
    y = 412,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "EASTERN SHORE SPAWN #2",
    x = 57,
    y = 331,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "EASTERN SHORE SPAWN #3",
    x = 149,
    y = 231,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "FACTORY SPAWN #1",
    x = 494,
    y = 410,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "FACTORY SPAWN #2",
    x = 318,
    y = 388,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "SOUTHERN MILITARY CAMP SPAWN #1",
    x = 369,
    y = 490,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "SOUTHERN MILITARY CAMP SPAWN #2",
    x = 459,
    y = 473,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "NORTHERN SHORE SPAWN #1",
    x = 575,
    y = 120,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "NORTHERN SHORE SPAWN #2",
    x = 369,
    y = 62,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "TRAILER PARK SPAWN",
    x = 699,
    y = 316,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "EASTERN MILITARY CAMP SPAWN #1",
    x = 341,
    y = 183,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "GARAGE SPAWN",
    x = 588,
    y = 249,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "NORTHERN MILITARY CAMP SPAWN #1",
    x = 463,
    y = 198,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "STORAGE CENTER SPAWN",
    x = 571,
    y = 397,
    z = 0
})

------------------------------------------
---* Permanent Extraction Points *-- 
--- Extraction point that will always be available, assuming PVP instance North Eastern point is at cell 0,0

--- Time taken to extract
PZ_EFT_CONFIG.PermanentExtractionPoints = {}


table.insert(PZ_EFT_CONFIG.PermanentExtractionPoints, {
    name = "Helipad",
    x1 = 423,
    y1 = 542,
    z1 = 0,
    x2 = 444,
    y2 = 565,
    z2 = 0,
    time = 10,
    isRandom = false
})



------------------------------------------
---* Random Extraction Points *-- 
--- Extraction point that won't always be available (PZ_EFT_CONFIG.PVPInstanceSettings.randomExtractionPointCount), assuming PVP instance North Eastern point is at cell 0,0

--- Time taken to extract
PZ_EFT_CONFIG.RandomExtractionPoints = {}


table.insert(PZ_EFT_CONFIG.RandomExtractionPoints, {
    name = "South West Dock",
    x1 = 42,
    y1 = 525,
    z1 = 0,
    x2 = 64,
    y2 = 550,
    z2 = 0,
    time = 10,
    isRandom = true
})

table.insert(PZ_EFT_CONFIG.RandomExtractionPoints, {
    name = "North East Dock",
    x1 = 812,
    y1 = 223,
    z1 = 0,
    x2 = 848,
    y2 = 237,
    z2 = 0,
    time = 10,
    isRandom = true
})

table.insert(PZ_EFT_CONFIG.RandomExtractionPoints, {
    name = "South East Dock",
    x1 = 794,
    y1 = 508,
    z1 = 0,
    x2 = 801,
    y2 = 525,
    z2 = 0,
    time = 10,
    isRandom = true
})


table.insert(PZ_EFT_CONFIG.RandomExtractionPoints, {
    name = "North West Dock",
    x1 = 212,
    y1 = 85,
    z1 = 0,
    x2 = 217,
    y2 = 110,
    z2 = 0,
    time = 10,
    isRandom = true
})

--------------------------------------------------
--* Starter kit setup

---@alias starterKitType {fullType : string, amount : number}


---@type starterKitType
PZ_EFT_CONFIG.StarterKit = {}
table.insert(PZ_EFT_CONFIG.StarterKit, {fullType = "Base.Pistol", amount = 4})
table.insert(PZ_EFT_CONFIG.StarterKit, {fullType = "Base.9mmClip", amount = 8})
table.insert(PZ_EFT_CONFIG.StarterKit, {fullType = "Base.Bullets9mmBox", amount = 4})
table.insert(PZ_EFT_CONFIG.StarterKit, {fullType = "Base.DoubleBarrelShotgun", amount = 4})
table.insert(PZ_EFT_CONFIG.StarterKit, {fullType = "Base.ShotgunShellsBox", amount = 2})
table.insert(PZ_EFT_CONFIG.StarterKit, {fullType = "Base.Hat_Army", amount = 4})
table.insert(PZ_EFT_CONFIG.StarterKit, {fullType = "Base.Shoes_ArmyBoots", amount = 4})
table.insert(PZ_EFT_CONFIG.StarterKit, {fullType = "Base.Vest_BulletPolice", amount = 4})
table.insert(PZ_EFT_CONFIG.StarterKit, {fullType = "Base.Bag_DuffelBag", amount = 4})
table.insert(PZ_EFT_CONFIG.StarterKit, {fullType = "Base.WaterBottleFull", amount = 4})
table.insert(PZ_EFT_CONFIG.StarterKit, {fullType = "Base.Cereal", amount = 2})
table.insert(PZ_EFT_CONFIG.StarterKit, {fullType = "Base.Crisps", amount = 4})
table.insert(PZ_EFT_CONFIG.StarterKit, {fullType = "Base.HuntingKnife", amount = 4})
table.insert(PZ_EFT_CONFIG.StarterKit, {fullType = "Base.Bandage", amount = 8})


---@alias starterKitLocationsType {crateIndex : number}


PZ_EFT_CONFIG.StarterKitLocations = {}

PZ_EFT_CONFIG.StarterKitLocations["Base.Pistol"] = {
    crateIndex = 1,
    [1] = {x = 0, y = 4, isRotated = false},
    [2] = {x = 2, y = 4, isRotated = false},
    [3] = {x = 4, y = 4, isRotated = false},
    [4] = {x = 6, y = 4, isRotated = false},
}
PZ_EFT_CONFIG.StarterKitLocations["Base.DoubleBarrelShotgun"] = {
    crateIndex = 1,
    [1] = {x = 0, y = 0, isRotated = false},
    [2] = {x = 5, y = 0, isRotated = false},
    [3] = {x = 0, y = 2, isRotated = false},
    [4] = {x = 5, y = 2, isRotated = false},
}

PZ_EFT_CONFIG.StarterKitLocations["Base.Bullets9mmBox"] = {
    crateIndex = 1,
    [1] = {x = 8, y = 4, isRotated = false},
    [2] = {x = 8, y = 4, isRotated = false},
    [3] = {x = 8, y = 4, isRotated = false},
    [4] = {x = 8, y = 4, isRotated = false},
}

PZ_EFT_CONFIG.StarterKitLocations["Base.ShotgunShellsBox"] = {
    crateIndex = 1,
    [1] = {x = 9, y = 4, isRotated = false},
    [2] = {x = 9, y = 4, isRotated = false},
    [3] = {x = 9, y = 4, isRotated = false},
    [4] = {x = 9, y = 4, isRotated = false},
}

PZ_EFT_CONFIG.StarterKitLocations["Base.HuntingKnife"] = {
    crateIndex = 1,
    [1] = {x = 8, y = 5, isRotated = true},
    [2] = {x = 8, y = 6, isRotated = true},
    [3] = {x = 8, y = 7, isRotated = true},
    [4] = {x = 8, y = 8, isRotated = true},
}

PZ_EFT_CONFIG.StarterKitLocations["Base.9mmClip"] = {
    crateIndex = 1,
    [1] = {x = 0, y = 5, isRotated = true},
    [2] = {x = 2, y = 5, isRotated = true},
    [3] = {x = 4, y = 5, isRotated = true},
    [4] = {x = 6, y = 5, isRotated = true},
    [5] = {x = 0, y = 6, isRotated = true},
    [6] = {x = 2, y = 6, isRotated = true},
    [7] = {x = 4, y = 6, isRotated = true},
    [8] = {x = 6, y = 6, isRotated = true},
}
PZ_EFT_CONFIG.StarterKitLocations["Base.WaterBottleFull"] = {
    crateIndex = 2,
    [1] = {x = 0, y = 0, isRotated = true},
    [2] = {x = 2, y = 0, isRotated = true},
    [3] = {x = 4, y = 0, isRotated = true},
    [4] = {x = 6, y = 0, isRotated = true},
}
PZ_EFT_CONFIG.StarterKitLocations["Base.Crisps"] = {
    crateIndex = 2,
    [1] = {x = 8, y = 0, isRotated = false},
    [2] = {x = 8, y = 1, isRotated = false},
    [3] = {x = 8, y = 2, isRotated = false},
    [4] = {x = 8, y = 3, isRotated = false},
}
PZ_EFT_CONFIG.StarterKitLocations["Base.Cereal"] = {
    crateIndex = 2,
    [1] = {x = 6, y = 1, isRotated = false},
    [2] = {x = 6, y = 3, isRotated = false},
}
PZ_EFT_CONFIG.StarterKitLocations["Base.Bandage"] = {
    crateIndex = 2,
    [1] = {x = 9, y = 0, isRotated = true},
    [2] = {x = 9, y = 1, isRotated = true},
    [3] = {x = 9, y = 2, isRotated = true},
    [4] = {x = 9, y = 3, isRotated = true},
    [5] = {x = 9, y = 4, isRotated = true},
    [6] = {x = 9, y = 5, isRotated = true},
    [7] = {x = 9, y = 6, isRotated = true},
    [8] = {x = 9, y = 7, isRotated = true},
}
PZ_EFT_CONFIG.StarterKitLocations["Base.Vest_BulletPolice"] = {
    crateIndex = 2,
    [1] = {x = 0, y = 1, isRotated = false},
    [2] = {x = 3, y = 1, isRotated = false},
    [3] = {x = 0, y = 4, isRotated = false},
    [4] = {x = 0, y = 7, isRotated = false},
}
PZ_EFT_CONFIG.StarterKitLocations["Base.Hat_Army"] = {
    crateIndex = 2,
    [1] = {x = 3, y = 4, isRotated = false},
    [2] = {x = 3, y = 4, isRotated = false},
    [3] = {x = 3, y = 6, isRotated = false},
    [4] = {x = 3, y = 6, isRotated = false},
}
PZ_EFT_CONFIG.StarterKitLocations["Base.Shoes_ArmyBoots"] = {
    crateIndex = 2,
    [1] = {x = 3, y = 8, isRotated = false},
    [2] = {x = 4, y = 8, isRotated = false},
    [3] = {x = 5, y = 8, isRotated = false},
    [4] = {x = 6, y = 8, isRotated = false},
}
PZ_EFT_CONFIG.StarterKitLocations["Base.Bag_DuffelBag"] = {
    crateIndex = 3,
    [1] = {x = 0, y = 0, isRotated = false},
    [2] = {x = 3, y = 0, isRotated = false},
    [3] = {x = 0, y = 4, isRotated = false},
    [4] = {x = 3, y = 4, isRotated = false},
}

---------------------------------------------------
-- --* Sandbox Vars override
-- local function ForceSetSandboxVars()
--     debugPrint("Setting foced Sandbox Vars")
--     local options = SandboxOptions.new()
-- 	options:copyValuesFrom(getSandboxOptions())

--     options['Zombies'] = 5
--     options['WaterShutModifier'] = 2147483647
--     options['ElecShutModifier'] = 2147483647

--     options:sendToServer()
-- end

-- Events.OnGameStart.Add(ForceSetSandboxVars)