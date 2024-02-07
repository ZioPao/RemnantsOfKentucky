-- -- TODO Implement them
if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")
local LootRecapHandler = require("ROK/Match/LootRecapHandler")


TestFramework.registerTestModule("Gameplay", "Debug", function()
    local Tests = {}
    local function StartMatch()
        local TimePanel = require("ROK/UI/TimePanel")
        sendClientCommand(EFT_MODULES.Match, "StartCountdown", { stopTime = PZ_EFT_CONFIG.MatchSettings.startMatchTime })
        TimePanel.Open("Starting match in...")
    end

    local function CloseRecapScreen()
        local RecapPanel = require("ROK/UI/AfterMatch/RecapPanel")
        RecapPanel.Close()
    end

    local function ExecuteExtraction()
        local instance = ClientData.PVPInstances.GetCurrentInstance()
        local extractionPoints = instance.extractionPoints

        local point = extractionPoints[1]
        local x = point.x1
        local y = point.y1

        local pl = getPlayer()
        pl:setX(x)
        pl:setY(y)
        pl:setLx(x)
        pl:setLy(y)
        local Delay = require("ROK/Delay")

        Delay:set(2, function()
            debugPrint("TEST: EXTRACTION!")
            local ExtractionHandler = require("ROK/Match/ExtractionHandler")
            ExtractionHandler.DoExtraction()


            Delay:set(2, CloseRecapScreen)


        end)
    end



    

    function Tests.LoopStartEndMatch()


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

    function Tests.StartMatch()
        StartMatch()
    end

    function Tests.ExecuteExtraction()
        ExecuteExtraction()
    end

    function Tests.StartMatchAndExtract()
        StartMatch()

        local Delay = require("ROK/Delay")
        Delay:set(10, ExecuteExtraction)

    end


    function Tests.LoopStartMatchAndExtract()
        StartMatch()
        local Delay = require("ROK/Delay")
        Delay:set(10, ExecuteExtraction)

        Events.PZEFT_OnMatchEnd.Add(function()
            -- Start match
            StartMatch()
            Delay:set(10, ExecuteExtraction)
        end)

    end

    return Tests

end)

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


    return Tests
end)


TestFramework.registerTestModule("UI", "KillTracker", function()
    
    local Tests = {}
    
    local KillTrackerHandler = require("ROK/Match/KillTrackerHandler")

    function Tests.AddFakeKill()
        KillTrackerHandler.Init()
        KillTrackerHandler.AddKill("Fake Kill1", os.time())
        KillTrackerHandler.AddKill("Fake Kill2", os.time() + 10)
        KillTrackerHandler.AddKill("Fake Kill3", os.time() + 100)
        KillTrackerHandler.AddKill("Fake Kill4", os.time() + 1000)
    end


    return Tests

end)