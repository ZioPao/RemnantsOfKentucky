PZ_EFT_CONFIG = PZ_EFT_CONFIG or {}

PZ_EFT_CONFIG.Debug = true

PZ_EFT_CONFIG.SafehouseCells = {{
    x = 1,
    y = 1
}}

PZ_EFT_CONFIG.SafehouseInstanceSettings = {
    firstSafehouse = {
        relative = {
            x = 8,
            y = 19,
            z = 0
        }
    },
    safehouseGrid = {
        x = {
            count = 5,
            spacing = 60
        },
        y = {
            count = 5,
            spacing = 60
        }
    },

    -- Storage boxes will be placed alwyas in the same point inside a safehouse.
    storageRelativePosition = {
        x = 1,
        y = 1,
    },

    ---Dimensions of safehouse, relative to the entrance
    dimensions = {
        n = 16,
        s = 1,
        e = 1,
        w = 6
    }
}

PZ_EFT_CONFIG.PVPInstanceSettings = {
    xLength = 2,
    yLength = 3,

    buffer = 1,

    firstXCellPos = 3,
    firstYCellPos = 2,

    xRepeat = 4,
    yRepeat = 4,

    randomExtractionPointCount = 3
}

PZ_EFT_CONFIG.MatchSettings = {
    time = 30,      -- TODO Maybe it's better if we set it in seconds here instead of minutes
    overTime = 5
}

--- Spawn points - world coordinates if PVP instance starts at cell 0,0
PZ_EFT_CONFIG.Spawnpoints = {}

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    x = 5,
    y = 5,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    x = 67,
    y = 24,
    z = 0
})

table.insert(PZ_EFT_CONFIG.Spawnpoints, {
    x = 402,
    y = 200,
    z = 0
})

--- Extraction point that will always be available, assuming PVP instance North Eastern point is at cell 0,0
--- Time taken to extract
--- Radius of extraction zone
PZ_EFT_CONFIG.PermanentExtractionPoints = {}

table.insert(PZ_EFT_CONFIG.PermanentExtractionPoints, {
    x = 5,
    y = 5,
    z = 0,
    time = 10,
    radius = 3,
})

table.insert(PZ_EFT_CONFIG.PermanentExtractionPoints, {
    x = 5,
    y = 58,
    z = 2,
    time = 10,
    radius = 3,
})


--- Extraction point that won't always be available (PZ_EFT_CONFIG.PVPInstanceSettings.randomExtractionPointCount), assuming PVP instance North Eastern point is at cell 0,0
--- Time taken to extract
--- Radius of extraction zone
PZ_EFT_CONFIG.RandomExtractionPoints = {}

table.insert(PZ_EFT_CONFIG.RandomExtractionPoints, {
    x = 500,
    y = 550,
    z = 1,
    time = 10,
    radius = 3,
})

table.insert(PZ_EFT_CONFIG.RandomExtractionPoints, {
    x = 200,
    y = 300,
    z = 0,
    time = 10,
    radius = 3,
})

table.insert(PZ_EFT_CONFIG.RandomExtractionPoints, {
    x = 54,
    y = 56,
    z = 0,
    time = 10,
    radius = 3,
})
