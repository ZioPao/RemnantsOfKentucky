-- -- TODO Implement them
if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")
local LootRecapHandler = require("ROK/Match/LootRecapHandler")

TestFramework.registerTestModule("PVP Instances", "Debug", function()

    local Tests = {}
    function Tests.PrintPvpInstances()
        ServerData_client_debug.print_pvp_instances()
    end

    function Tests.RunBeforeMatchLootRecap()
        LootRecapHandler.SaveInventory(true)
    end

    function Tests.RunAfterMatchLootRecap()
        LootRecapHandler.SaveInventory(false)
    end

    function Tests.CompareLoot()
        local items = LootRecapHandler.CompareWithOldInventory()
        PZEFT_UTILS.PrintTable(items)
    end


    return Tests
end)

TestFramework.registerTestModule("Bank", "Debug", function()

    local Tests = {}
    function Tests.GiveMoney()
        ServerData_client_debug.setBankAccount(getPlayer():getUsername(), 1000000)
    end

    return Tests
end)

TestFramework.registerTestModule("Various", "Player", function()
    local Tests = {}

    function Tests.Kill()
        getPlayer():Kill(getPlayer())
    end

    function Tests.Random()
        local size = 2
        local value = ZombRand(size) + 1
        print(value)
    end

    return Tests
end)
--local RecapPanel = require("ROK/UI/AfterMatch/RecapPanel")

TestFramework.registerTestModule("UI", "Debug", function()
    local RecapPanel = require("ROK/UI/AfterMatch/RecapPanel")

    local Tests = {}
    function Tests.OpenRecapPanel()
        RecapPanel.Open()
    end

    function Tests.CloseRecapPanel()
        RecapPanel.Close()
    end


    function Tests.LoopStartEndMatch()



        local function StartMatch()
            local TimePanel = require("ROK/UI/TimePanel")
            sendClientCommand(EFT_MODULES.Match, "StartCountdown", { stopTime = PZ_EFT_CONFIG.MatchSettings.startMatchTime })
            TimePanel.Open("Starting match in...")
        end

        local function StopMatch()
            sendClientCommand(EFT_MODULES.Match, "StartMatchEndCountdown", { stopTime = PZ_EFT_CONFIG.MatchSettings.endMatchTime })

        end

        StartMatch()

        Events.PZEFT_OnMatchStart.Add(function()
            -- Stop Match
            StopMatch()
        end)


        Events.PZEFT_OnMatchEnd.Add(function()
            -- Start match
            StartMatch()
        end)





    end

    return Tests
end)