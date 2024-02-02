
require "ROK/ClientData"
-----------------------

---@class AdminShopManager
local AdminShopManager = {}


--- Adjust an item's price multiplier
---@param fullType String
---@param newMultiplier number decimal
---@return boolean
function AdminShopManager.AdjustItem(fullType, newMultiplier, sellMultiplier)
    -- TODO Do we need this?
end

--- Manually refreshes the daily items
function AdminShopManager.RefreshDailyItems()
    -- TODO Reimplement

end

-------------------------------------------------------------------



return AdminShopManager