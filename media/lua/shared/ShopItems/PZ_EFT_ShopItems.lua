PZ_EFT_ShopItems_Config = PZ_EFT_ShopItems_Config or {} 
PZ_EFT_ShopItems_Config.data = {}

--- Add shop item
---@param fullType string
---@param basePrice integer
---@param initialMultiplier integer
---@param sellMultiplier integer
PZ_EFT_ShopItems_Config.addItem = function(fullType, basePrice, initialMultiplier, sellMultiplier)
    PZ_EFT_ShopItems_Config.data[fullType] = {fullType = fullType, basePrice = basePrice, multiplier = initialMultiplier or 1, sellMultiplier = sellMultiplier or 1 }
end



