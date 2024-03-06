---@class PZ_EFT_CONFIG
PZ_EFT_CONFIG = {}
PZ_EFT_CONFIG.Client = {}
PZ_EFT_CONFIG.Server = {}


PZ_EFT_CONFIG.Debug = true


PZ_EFT_CONFIG.SupportedMods = {
    ["ROK"] = true,
    ["INVENTORY_TETRIS"] = true,
    ["VFExpansion1"] = true,
    ["Advanced_trajectory"] = true,
    ["diveThroughWindows"] = true,
    ["tsarslib"] = true,
    ["TMC_TrueActions"] = true,
    ["TrueActionsDancing"] = true,
    ["MoodleFramework"] = true,
    ["ToadTraits"] = true,
    ["modoptions"] = true,
    ["BasicCrafting"] = true,
    ["OutTheWindow"] = true,
    ["RainWash"] = true,
    ["TheStar"] = true,
    ["DylansZombieLoot"] = true,
    ["BetterFlashlights"] = true,
    ["DRAW_ON_MAP"] = true,
    ["VISIBLE_BACKPACK_BACKGROUND"] = true,
    ["BecomeDesensitized"] = true,
    ["GeneratorTimeRemaining"] = true,
    ["FuelAPI"] = true,
    ["Brita_2"] = true,
    ["BigBadBeaverMerch"] = true,
    ["P4HasBeenRead"] = true,
    ["BCGRareWeapons"] = true,
    ["MoreDescriptionForTraits4166"] = true,
    ["Skizots Visible Boxes and Garbage2"] = true,
    ["FancyHandwork"] = true,
    ["OneHandedSODBShotgun"] = true,
    ["fuelsideindicator"] = true,
    ["Gun Stock Attack Remaster"] = true,
    ["ZombiesHearYourMicrophone"] = true,
    ["eris_nightvision_goggles"] = true,
    ["NightVisionChucked"] = true,
    ["EQUIPMENT_UI"] = true,
}

--* MATCH

PZ_EFT_CONFIG.Client.Match = {

    -- How long until the match start
    startMatchTime = 5,

    -- How long until the match ends after a forced stop
    endMatchTime = 5
}

PZ_EFT_CONFIG.Server.Match = {

    -- How long inbetween zombie spawns in seconds
    zombieIncreaseTime = 60,

    -- Start amount of zombies. With default settings, it hovers around 1000-1200 zombies at most
    zombiesAmountBase = 2,

    -- Multiplier for zombie spawns, customizable via admin panel
    zombieSpawnMultiplier = 2,

    -- Chance of a fake sound playing on a player to attract zombies
    chanceRandomSoundOnZombieSpawn = 50,

    -- Time between pings
    checkAlivePlayersTime = 10
}

--* PLAYER DEFAULT VALUES

PZ_EFT_CONFIG.DefaultPlayer = {
    balance = 10000
}

--* SAFEHOUSES
--Cells containing safehouses for initialisation
PZ_EFT_CONFIG.SafehouseCells = {
    {
        x = 100,
        y = 100
    },
    {
        x = 100,
        y = 101
    }
}


PZ_EFT_CONFIG.SpawnCell = {
    x = 150,
    y = 150
}


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
        { x = 39 - relativeSafehouseEntrance.x, y = 21 - relativeSafehouseEntrance.y },
        { x = 40 - relativeSafehouseEntrance.x, y = 21 - relativeSafehouseEntrance.y },
        { x = 41 - relativeSafehouseEntrance.x, y = 21 - relativeSafehouseEntrance.y },
    },

    safehouseMovDeliveryPoint = {
        x = 41 - relativeSafehouseEntrance.x,
        y = 23 - relativeSafehouseEntrance.y
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
    firstXCellPos = 100,
    -- first instance y cell position
    firstYCellPos = 0,

    -- how many times instances repeat in an x direction
    xRepeat = 10,
    -- how many times instances repeat in a y direction
    yRepeat = 10,

    -- -- number of random extraction points for each instance
    -- randomExtractionPointCount = 3      -- TODO Make it customizable or random
}

PZ_EFT_CONFIG.Shop = {
    dailyItemsAmount = 30,
    instaHealCost = 2500
}

------------------------------------------
---* Spawn points *--
-- World coordinates if PVP instance starts at cell 0,0

local function InsertGenericSpawnpoint(tab, name, x, y, z)
    table.insert(tab, { name = name, x = x, y = y, z = z })
end

---@alias spawnPointsType {name : string, x : integer, y : integer, z : integer}

---@type table<integer, spawnPointsType>
PZ_EFT_CONFIG.Spawnpoints = {}

local function InsertSpawnpoint(name, x, y, z)
    table.insert(PZ_EFT_CONFIG.Spawnpoints, { name = name, x = x, y = y, z = z })
end

InsertSpawnpoint("SOUTHERN SHORE SPAWN #1", 525, 559, 0)
InsertSpawnpoint("SOUTHERN SHORE SPAWN #2", 219, 540, 0)
InsertSpawnpoint("SOUTHERN SHORE SPAWN #3", 34, 524, 0)
InsertSpawnpoint("RADIO TOWER SPAWN", 715, 503, 0)
InsertSpawnpoint("WESTERN SHORE SPAWN #1", 848, 445, 0)
--InsertSpawnpoint("WESTERN SHORE SPAWN #2", 854, 226, 0) --FIX Broken spawnpoint
InsertSpawnpoint("MEDICAL CENTER BATHROOMS SPAWN", 153, 425, 0)
InsertSpawnpoint("EASTERN SHORE SPAWN #1", 29, 412, 0)
InsertSpawnpoint("EASTERN SHORE SPAWN #2", 57, 331, 0)
InsertSpawnpoint("EASTERN SHORE SPAWN #3", 149, 231, 0)
InsertSpawnpoint("FACTORY SPAWN #1", 494, 410, 0)
InsertSpawnpoint("FACTORY SPAWN #2", 318, 388, 0)
InsertSpawnpoint("SOUTHERN MILITARY CAMP SPAWN #1", 369, 490, 0)
InsertSpawnpoint("SOUTHERN MILITARY CAMP SPAWN #2", 459, 473, 0)
InsertSpawnpoint("NORTHERN SHORE SPAWN #1", 575, 120, 0)
InsertSpawnpoint("NORTHERN SHORE SPAWN #2", 369, 62, 0)
InsertSpawnpoint("TRAILER PARK SPAWN", 699, 316, 0)
InsertSpawnpoint("EASTERN MILITARY CAMP SPAWN #1", 341, 183, 0)
InsertSpawnpoint("GARAGE SPAWN", 588, 249, 0)
InsertSpawnpoint("NORTHERN MILITARY CAMP SPAWN #1", 463, 198, 0)
InsertSpawnpoint("STORAGE CENTER SPAWN", 571, 397, 0)


------------------------------------------
---* Permanent Extraction Points *--
--- Extraction point that will always be available, assuming PVP instance North Eastern point is at cell 0,0


---@param tab table
---@param name string
---@param x1 number
---@param y1 number
---@param z1 number
---@param x2 number
---@param y2 number
---@param z2 number
---@param isRandom boolean
local function InsertGenericExtractionPoint(tab, name, x1, y1, z1, x2, y2, z2, isRandom)
    table.insert(tab,
        { name = name, x1 = x1, y1 = y1, z1 = z1, x2 = x2, y2 = y2, z2 = z2, time = 10, isRandom = isRandom })
end

--- Time taken to extract
PZ_EFT_CONFIG.PermanentExtractionPoints = {}
InsertGenericExtractionPoint(PZ_EFT_CONFIG.PermanentExtractionPoints, "HELIPAD", 423, 542, 0, 444, 565, 0, false)


------------------------------------------
---* Random Extraction Points *--
--[[
Extraction point that won't always be available
(PZ_EFT_CONFIG.PVPInstanceSettings.randomExtractionPointCount), assuming PVP instance North Eastern point is at cell 0,0
]]

--- Time taken to extract
PZ_EFT_CONFIG.RandomExtractionPoints = {}

local function InsertRandomExtractionPoint(name, x1, y1, z1, x2, y2, z2)
    InsertGenericExtractionPoint(PZ_EFT_CONFIG.RandomExtractionPoints, name, x1, y1, z1, x2, y2, z2, true)
end

InsertRandomExtractionPoint("SOUTH WEST DOCK", 42, 525, 0, 64, 550, 0)
InsertRandomExtractionPoint("NORTH EAST DOCK", 812, 223, 0, 848, 237, 0)
InsertRandomExtractionPoint("SOUTH EAST DOCK", 794, 508, 0, 801, 525, 0)
InsertRandomExtractionPoint("NORTH WEST DOCK", 212, 85, 0, 217, 110, 0)

--------------------------------------------------
--* Starter kit setup


-- ---@type starterKitType
-- PZ_EFT_CONFIG.StarterKit = {}


-- table.insert(PZ_EFT_CONFIG.StarterKit, { fullType = "Base.Pistol", amount = 4 })
-- table.insert(PZ_EFT_CONFIG.StarterKit, { fullType = "Base.9mmClip", amount = 8 })
-- table.insert(PZ_EFT_CONFIG.StarterKit, { fullType = "Base.Bullets9mmBox", amount = 4 })
-- table.insert(PZ_EFT_CONFIG.StarterKit, { fullType = "Base.DoubleBarrelShotgun", amount = 4 })
-- table.insert(PZ_EFT_CONFIG.StarterKit, { fullType = "Base.ShotgunShellsBox", amount = 2 })
-- table.insert(PZ_EFT_CONFIG.StarterKit, { fullType = "Base.Hat_Army", amount = 4 })
-- table.insert(PZ_EFT_CONFIG.StarterKit, { fullType = "Base.Shoes_ArmyBoots", amount = 4 })
-- table.insert(PZ_EFT_CONFIG.StarterKit, { fullType = "Base.Vest_BulletPolice", amount = 4 })
-- table.insert(PZ_EFT_CONFIG.StarterKit, { fullType = "Base.Bag_DuffelBag", amount = 4 })
-- table.insert(PZ_EFT_CONFIG.StarterKit, { fullType = "Base.WaterBottleFull", amount = 4 })
-- table.insert(PZ_EFT_CONFIG.StarterKit, { fullType = "Base.Cereal", amount = 2 })
-- table.insert(PZ_EFT_CONFIG.StarterKit, { fullType = "Base.Crisps", amount = 4 })
-- table.insert(PZ_EFT_CONFIG.StarterKit, { fullType = "Base.HuntingKnife", amount = 4 })
-- table.insert(PZ_EFT_CONFIG.StarterKit, { fullType = "Base.Bandage", amount = 8 })


---@alias starterKitPosition table<integer,{x:number, y:number, isRotated:boolean}>

---@alias starterKitElement {fullType : string, crateIndex : number, positions : starterKitPosition}
---@alias starterKitType table<integer, starterKitElement>

---@type starterKitType
PZ_EFT_CONFIG.StarterKit = {}

---@param fullType string
---@param crateIndex number
---@param positions starterKitPosition
local function AddToStarterKit(fullType, crateIndex, positions)
    table.insert(PZ_EFT_CONFIG.StarterKit, {
        fullType = fullType,
        crateIndex = crateIndex,
        positions = positions
    })
end

AddToStarterKit("Base.Pistol", 1, {
    [1] = { x = 0, y = 4, isRotated = false },
    [2] = { x = 2, y = 4, isRotated = false },
    [3] = { x = 4, y = 4, isRotated = false },
    [4] = { x = 6, y = 4, isRotated = false },
})

AddToStarterKit("Base.DoubleBarrelShotgun", 1, {
    [1] = { x = 0, y = 0, isRotated = false },
    [2] = { x = 5, y = 0, isRotated = false },
    [3] = { x = 0, y = 2, isRotated = false },
    [4] = { x = 5, y = 2, isRotated = false },
})

AddToStarterKit("Base.Bullets9mmBox", 1, {
    [1] = { x = 8, y = 4, isRotated = false },
    [2] = { x = 8, y = 4, isRotated = false },
    [3] = { x = 8, y = 4, isRotated = false },
    [4] = { x = 8, y = 4, isRotated = false },
})

AddToStarterKit("Base.ShotgunShellsBox", 1, {
    [1] = { x = 9, y = 4, isRotated = false },
    [2] = { x = 9, y = 4, isRotated = false },
    [3] = { x = 9, y = 4, isRotated = false },
    [4] = { x = 9, y = 4, isRotated = false },
})

AddToStarterKit("Base.HuntingKnife", 1, {
    [1] = { x = 8, y = 5, isRotated = true },
    [2] = { x = 8, y = 6, isRotated = true },
    [3] = { x = 8, y = 7, isRotated = true },
    [4] = { x = 8, y = 8, isRotated = true },
})

AddToStarterKit("Base.9mmClip", 1, {
    [1] = { x = 0, y = 5, isRotated = true },
    [2] = { x = 2, y = 5, isRotated = true },
    [3] = { x = 4, y = 5, isRotated = true },
    [4] = { x = 6, y = 5, isRotated = true },
    [5] = { x = 0, y = 6, isRotated = true },
    [6] = { x = 2, y = 6, isRotated = true },
    [7] = { x = 4, y = 6, isRotated = true },
    [8] = { x = 6, y = 6, isRotated = true },
})

AddToStarterKit("Base.WaterBottleFull", 2, {
    [1] = { x = 0, y = 0, isRotated = true },
    [2] = { x = 2, y = 0, isRotated = true },
    [3] = { x = 4, y = 0, isRotated = true },
    [4] = { x = 6, y = 0, isRotated = true },
})

AddToStarterKit("Base.Crisps", 2, {
    [1] = { x = 8, y = 0, isRotated = false },
    [2] = { x = 8, y = 1, isRotated = false },
    [3] = { x = 8, y = 2, isRotated = false },
    [4] = { x = 8, y = 3, isRotated = false },
})

AddToStarterKit("Base.Cereal", 2, {
    [1] = { x = 6, y = 1, isRotated = false },
    [2] = { x = 6, y = 3, isRotated = false },
})

AddToStarterKit("Base.Bandage", 2, {
    [1] = { x = 9, y = 0, isRotated = true },
    [2] = { x = 9, y = 1, isRotated = true },
    [3] = { x = 9, y = 2, isRotated = true },
    [4] = { x = 9, y = 3, isRotated = true },
    [5] = { x = 9, y = 4, isRotated = true },
    [6] = { x = 9, y = 5, isRotated = true },
    [7] = { x = 9, y = 6, isRotated = true },
    [8] = { x = 9, y = 7, isRotated = true },
})

AddToStarterKit("Base.Vest_BulletPolice", 2, {
    [1] = { x = 0, y = 1, isRotated = false },
    [2] = { x = 3, y = 1, isRotated = false },
    [3] = { x = 0, y = 4, isRotated = false },
    [4] = { x = 0, y = 7, isRotated = false },
})

AddToStarterKit("Base.Hat_Army", 2, {
    [1] = { x = 3, y = 4, isRotated = false },
    [2] = { x = 3, y = 4, isRotated = false },
    [3] = { x = 3, y = 6, isRotated = false },
    [4] = { x = 3, y = 6, isRotated = false },
})

AddToStarterKit("Base.Shoes_ArmyBoots", 2, {
    [1] = { x = 3, y = 8, isRotated = false },
    [2] = { x = 4, y = 8, isRotated = false },
    [3] = { x = 5, y = 8, isRotated = false },
    [4] = { x = 6, y = 8, isRotated = false },
})

AddToStarterKit("Base.HolsterSimple", 2, {
    [1] = { x = 5, y = 4, isRotated = false },
    [2] = { x = 5, y = 5, isRotated = false },
    [3] = { x = 5, y = 6, isRotated = false },
    [4] = { x = 5, y = 7, isRotated = false }
})

AddToStarterKit("Base.Bag_DuffelBag", 3, {
    [1] = { x = 0, y = 0, isRotated = false },
    [2] = { x = 3, y = 0, isRotated = false },
    [3] = { x = 0, y = 4, isRotated = false },
    [4] = { x = 3, y = 4, isRotated = false },
})

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
