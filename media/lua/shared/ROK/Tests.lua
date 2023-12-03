-- TODO Implement them
if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")

TestFramework.registerTestModule("Test", "Test1", function()

end)