-- -- TODO Implement them
if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")

TestFramework.registerTestModule("PVP Instances", "Debug", function()

    local Tests = {}
    function Tests.PrintPvpInstances()
        ServerData_client_debug.print_pvp_instances()
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