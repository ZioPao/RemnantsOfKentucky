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