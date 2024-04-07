require('Items/Distributions')
require('Items/SuburbsDistributions')


SuburbsDistributions = SuburbsDistributions or {}

SuburbsDistributions.armystorage.crate = {
    procedural = true,
    procList = {
        { name = "ArmyStorageGuns",        min = 0, max = 3,  weightChance = 40 },
        { name = "ArmyStorageMedical",     min = 0, max = 10, weightChance = 60 },
        { name = "ArmyStorageOutfit",      min = 0, max = 3,  weightChance = 60 },
        { name = "ArmySurplusFootwear",    min = 0, max = 4,  weightChance = 60 },
        { name = "ArmySurplusMisc",        min = 0, max = 20, weightChance = 60 },
        { name = "ArmyStorageElectronics", min = 0, max = 10, weightChance = 60 },
    }
}

SuburbsDistributions.armystorage.metal_shelves = {
    procedural = true,
    procList = {
        { name = "ArmyStorageGuns",        min = 0, max = 1,  weightChance = 40 },
        { name = "ArmyStorageMedical",     min = 0, max = 10, weightChance = 60 },
        { name = "ArmyStorageOutfit",      min = 0, max = 3,  weightChance = 60 },
        { name = "ArmySurplusFootwear",    min = 0, max = 1,  weightChance = 60 },
        { name = "ArmySurplusMisc",        min = 0, max = 25, weightChance = 77 },
        { name = "ArmyStorageElectronics", min = 0, max = 10, weightChance = 60 },
    }
}

SuburbsDistributions.armystorage.counter = {
    procedural = true,
    procList = {
        { name = "ArmyStorageGuns",        min = 0, max = 5,  weightChance = 40 },
        { name = "ArmyStorageMedical",     min = 0, max = 10, weightChance = 60 },
        { name = "ArmyStorageOutfit",      min = 0, max = 3,  weightChance = 60 },
        { name = "ArmySurplusFootwear",    min = 0, max = 1,  weightChance = 60 },
        { name = "ArmySurplusMisc",        min = 0, max = 20, weightChance = 60 },
        { name = "ArmyStorageElectronics", min = 0, max = 10, weightChance = 60 },
    }
}
