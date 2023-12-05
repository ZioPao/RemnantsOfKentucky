PZ_EFT_ShopItems_Config = PZ_EFT_ShopItems_Config or {} 
PZ_EFT_ShopItems_Config.data = {}

---@alias shopTags table  [JUNK, ESSENTIALS, HIGHVALUE, LOWVALUE]

---@alias shopItemElement {fullType : string, tags : shopTags, basePrice : number, multiplier : number, sellMultiplier : number }

--- Add shop item
---@param fullType itemFullType
---@param tags shopTags
---@param basePrice integer
---@param initialMultiplier integer
---@param sellMultiplier integer
PZ_EFT_ShopItems_Config.addItem = function(fullType, tags, basePrice, initialMultiplier, sellMultiplier)
    PZ_EFT_ShopItems_Config.data[fullType] = {fullType = fullType, tags = tags, basePrice = basePrice, multiplier = initialMultiplier or 1, sellMultiplier = sellMultiplier or 1 }
end



-- TODO Automatically loop through EVERY ITEM and add a cost based on something