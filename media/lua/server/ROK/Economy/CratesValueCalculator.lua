local SafehouseInstanceManager = require("ROK/SafehouseInstanceManager")
local ShopItemsManager = require("ROK/ShopItemsManager")

-- TODO Add to the bank account I guess?
local CratesValueCalculator = {}


---@return table<integer, ItemContainer>?
function CratesValueCalculator.GetCrates(username)
    local key = SafehouseInstanceManager.GetPlayerSafehouseKey(username)
    local safehouse = SafehouseInstanceManager.GetSafehouseInstanceByKey(key)

    local cratesTable = {}
    if safehouse == nil then
        debugPrint("ERROR: can't find safehouse for player " .. username)
        return
    end
    for _, group in pairs(PZ_EFT_CONFIG.SafehouseInstanceSettings.safehouseStorage) do
        local sq = getCell():getGridSquare(safehouse.x + group.x, safehouse.y + group.y, 0)
        if sq == nil then
            error("ERROR: Square not found while searching for crates")
            break
        end
        local objects = sq:getObjects()
        for i = 0, objects:size() - 1 do
            local obj = objects:get(i)
            local container = obj:getContainer()
            if container then table.insert(cratesTable, container) end
        end
    end

    --debugPrint("Found " .. #cratesTable .. " crates")

    return cratesTable
end

function CratesValueCalculator.GetValue(item)
    local fullType = item:getFullType()
    local shopItem = ShopItemsManager.GetItem(fullType)

    if shopItem then
        --debugPrint(fullType .. " : $" .. tostring(shopItem.basePrice))
        return shopItem.basePrice
    else
        print("Couldn't find item with fullType " .. item:getFullType())
        return 0
    end

end

---@param username string
---@return number
function CratesValueCalculator.CalculateValueAllItems(username)
    local crates = CratesValueCalculator.GetCrates(username)
    if crates == nil then return 0 end
    local value = 0
    for i=1, #crates do
        local crate = crates[i]
        local crateItems = crate:getItems()
        for j=0, crateItems:size() - 1 do
            local item = crateItems:get(j)
            value = value + CratesValueCalculator.GetValue(item)
        end
        -- TODO Get Items inside and calculate value
    end

    return value

    -- TODO save it somewhere
end

return CratesValueCalculator