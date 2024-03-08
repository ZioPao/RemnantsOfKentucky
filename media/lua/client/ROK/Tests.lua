if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")
local LootRecapHandler = require("ROK/Match/LootRecapHandler")
local Delay = require("ROK/Delay")

local function testDebugPrint(text)
    debugPrint("!!!!!!!!!!TESTFRAMEWORK!!!!!!!!!!!!! - " .. text)
end



TestFramework.registerTestModule("Gameplay", "Debug", function()
    local Tests = {}

    local TimePanel = require("ROK/UI/TimePanel")
    local RecapPanel = require("ROK/UI/AfterMatch/RecapPanel")
    local ExtractionHandler = require("ROK/Match/ExtractionHandler")


    local function StartMatch()
        testDebugPrint("Starting match")
        sendClientCommand(EFT_MODULES.Match, "StartCountdown", { stopTime = PZ_EFT_CONFIG.Client.Match.startMatchTime })
        TimePanel.Open("TEST Starting match in...")
    end

    local function CloseRecapScreen()
        testDebugPrint("Closing recap panel")
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

        Delay:set(2, function()
            --debugPrint("TEST: EXTRACTION!")
            ExtractionHandler.DoExtraction()


            Delay:set(5, CloseRecapScreen)


        end)
    end
    -- COMMON

    local function ExtractAtRandomTime()
        Delay:set(ZombRand(5,25), ExecuteExtraction)
    end

    -- function Tests.LoopStartEndMatch()
    --     local function StopMatch()
    --         sendClientCommand(EFT_MODULES.Match, "StartMatchEndCountdown", { stopTime = PZ_EFT_CONFIG.Client.Match.endMatchTime })
    --     end

    --     StartMatch()

    --     Events.PZEFT_OnMatchStart.Add(function()
    --         -- Stop Match
    --         StopMatch()
    --     end)


    --     Events.PZEFT_OnMatchEnd.Add(function()
    --         -- Start match
    --         StartMatch()
    --     end)
    -- end

    function Tests.StartMatch()
        StartMatch()
    end

    function Tests.ExecuteExtraction()
        ExecuteExtraction()
    end

    function Tests.StartMatchAndExtract()
        StartMatch()
        ExtractAtRandomTime()
    end



    --* ADMIN WHO STARTS MATCH HANDLING

    local ClientState = require("ROK/ClientState")

    local function LoopCheckAndRunAndExtract()
        local function CheckAndRunMatch()
            if not ClientState.isMatchRunning then
                testDebugPrint("Match ended, restarting it and rerunning extraction")
                Events.EveryOneMinute.Remove(CheckAndRunMatch)

                Delay:set(5, function()
                    StartMatch()
                    Delay:set(ZombRand(10,20), function()
                        ExecuteExtraction()
                    end)
                end)
            end
            sendClientCommand(EFT_MODULES.Match, 'CheckIsRunningMatch', {})

        end

        ClientState.isMatchRunning = true       -- Assume that it's true for now
        Events.EveryOneMinute.Remove(CheckAndRunMatch)
        Events.EveryOneMinute.Add(CheckAndRunMatch)
    end

    function Tests.LoopStartMatchAndExtract()
        -- First run
        StartMatch()
        ExtractAtRandomTime()

        local function InnerLoop()
            testDebugPrint("OnMatchEnd triggered")
            LoopCheckAndRunAndExtract()
        end


        Events.PZEFT_ClientNotInRaidAnymore.Add(InnerLoop)
    end


    --* PLAYERS
    function Tests.LoopExtractAtRandomTime()
        Events.PZEFT_ClientNowInRaid.Add(function()
            ExtractAtRandomTime()
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

TestFramework.registerTestModule("UI", "Debug", function()
    local RecapPanel = require("ROK/UI/AfterMatch/RecapPanel")

    local Tests = {}
    function Tests.OpenRecapPanel()
        RecapPanel.Open()
    end

    function Tests.CloseRecapPanel()
        RecapPanel.Close()
    end

    local CreditsScreen = require("ROK/UI/CreditsScreen")

    function Tests.OpenCreditsScreen()
        CreditsScreen.Open()
    end

    function Tests.CloseCreditsScreen()
        CreditsScreen.Close()
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