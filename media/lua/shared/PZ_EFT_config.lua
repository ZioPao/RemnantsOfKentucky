PZ_EFT_CONFIG = PZ_EFT_CONFIG or {}

PZ_EFT_CONFIG.Debug = true

--Cells containing safehouses for initialisation
PZ_EFT_CONFIG.SafehouseCells = {{
    x = 0,
    y = 0
},
{
    x = 0,
    y = 1
}}

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
    safehouseStaticRoom = {
        x1 = 38 - relativeSafehouseEntrance.x,
        y1 = 25 - relativeSafehouseEntrance.y,
        x2 = 41 - relativeSafehouseEntrance.x,
        y2 = 21 - relativeSafehouseEntrance.y
    },

    --- relative to entrance
    safehouseComputer = {
        x = 41 - relativeSafehouseEntrance.x,
        y = 24 - relativeSafehouseEntrance.y
    },
    
    --- relative to entrance
    safehouseStorage = {
        {x = 39 - relativeSafehouseEntrance.x, y = 21 - relativeSafehouseEntrance.y},
        {x = 40 - relativeSafehouseEntrance.x, y = 21 - relativeSafehouseEntrance.y},
        {x = 41 - relativeSafehouseEntrance.x, y = 21 - relativeSafehouseEntrance.y},
    },

    --- relative to entrance
    safehouseEntranceNoBuildArea = {
        x1 = 37 - relativeSafehouseEntrance.x,
        y1 = 28 - relativeSafehouseEntrance.y,
        x2 = 41 - relativeSafehouseEntrance.x,
        y2 = 29 - relativeSafehouseEntrance.y
    },

    ---Dimensions of safehouse, relative to the entrance
    dimensions = {
        n = 9,
        s = 1,
        e = 4,
        w = 6
    }
}

PZ_EFT_CONFIG.PVPInstanceSettings = {
    xLength = 1,
    yLength = 2,

    buffer = 1,

    firstXCellPos = 5,
    firstYCellPos = 5,

    xRepeat = 4,
    yRepeat = 2,

    randomExtractionPointCount = 1 --TODO: Maybe sandbox options
}

PZ_EFT_CONFIG.MatchSettings = {
    time = 30,      -- TODO Maybe it's better if we set it in seconds here instead of minutes
    overTime = 5
}

--- Spawn points - world coordinates if PVP instance starts at cell 0,0

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

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    name = "WESTERN SHORE SPAWN #2",
    x = 854,
    y = 226,
    z = 0
})

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

--- Extraction point that will always be available, assuming PVP instance North Eastern point is at cell 0,0
--- Time taken to extract
PZ_EFT_CONFIG.PermanentExtractionPoints = {}


table.insert(PZ_EFT_CONFIG.PermanentExtractionPoints, {
    name = "Extract 1",
    x1 = 37,
    y1 = 528,
    z1 = 0,
    x2 = 39,
    y2 = 538,
    z2 = 0,
    time = 10,
})

table.insert(PZ_EFT_CONFIG.PermanentExtractionPoints, {
    name = "Extract 2",
    x1 = 812,
    y1 = 227,
    z1 = 0,
    x2 = 831,
    y2 = 230,
    z2 = 0,
    time = 10,
})

table.insert(PZ_EFT_CONFIG.PermanentExtractionPoints, {
    name = "Extract 3",
    x1 = 769,
    y1 = 470,
    z1 = 0,
    x2 = 777,
    y2 = 472,
    z2 = 0,
    time = 10,
})

--- Extraction point that won't always be available (PZ_EFT_CONFIG.PVPInstanceSettings.randomExtractionPointCount), assuming PVP instance North Eastern point is at cell 0,0
--- Time taken to extract
PZ_EFT_CONFIG.RandomExtractionPoints = {}

--[[
table.insert(PZ_EFT_CONFIG.RandomExtractionPoints, {
    name = "extract point 1",
    x1 = 5,
    y1 = 5,
    z1 = 0,
    x2 = 5,
    y2 = 5,
    z2 = 0,
    time = 10,
})
--]]