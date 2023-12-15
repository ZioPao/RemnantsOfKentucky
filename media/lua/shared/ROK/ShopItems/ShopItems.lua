PZ_EFT_ShopItems_Config = PZ_EFT_ShopItems_Config or {}
PZ_EFT_ShopItems_Config.data = {}

---@alias shopTags table  [JUNK, ESSENTIALS, HIGHVALUE, LOWVALUE]

---@alias shopItemElement {fullType : string, tags : shopTags, basePrice : number, multiplier : number, sellMultiplier : number, quantity : number?}

--- Add shop item
---@param fullType itemFullType
---@param tags shopTags
---@param basePrice integer
---@param initialMultiplier integer
---@param sellMultiplier integer
function PZ_EFT_ShopItems_Config.AddItem(fullType, tags, basePrice, initialMultiplier, sellMultiplier)
    PZ_EFT_ShopItems_Config.data[fullType] = {fullType = fullType, tags = tags, basePrice = basePrice, multiplier = initialMultiplier or 1, sellMultiplier = sellMultiplier or 1 }
end

---@param fullType string
---@return shopItemElement
function PZ_EFT_ShopItems_Config.GetItem(fullType)
    ---@type shopItemElement
    local itemData = PZ_EFT_ShopItems_Config.data[fullType]

    if itemData == nil then
        -- Cache it
        PZ_EFT_ShopItems_Config.AddItem(fullType, {}, 100, 1, 0.5)
        itemData = PZ_EFT_ShopItems_Config.data[fullType]
    end

    return itemData
end

--- At startup and at every new day
function PZ_EFT_ShopItems_Config.GenerateDailyItems()
    -- Clean old Daily Items
    debugPrint("Generating daily items")

    for k,v in pairs(PZ_EFT_ShopItems_Config.data) do
    ---@cast v shopItemElement

        if v.tags.HIGHVALUE then
            PZ_EFT_ShopItems_Config.data[k] = nil
        end
    end

    local ignoredCat = {
        Hidden = true,
        ZedDmg = true,
        Wound = true,
        Mole = true,
        Bandage = true,
        MakeUp = true,

    }
    local allItems = getScriptManager():getAllItems()
    local counter = 0
	for i=1,allItems:size() do
        ---@type Item
		local item = allItems:get(i-1)
        local chance = ZombRand(0,100) > 90
        local price = ZombRand(100, 1000)

        if chance and item ~= nil and item:getFullName() ~= "ROK.InstaHeal" and not item:isHidden() then
            local itemName = item:getFullName()
            debugPrint("Adding to daily items " .. itemName)

            if itemName == "Base.Katana" then
                price = 20000
            end

            if PZ_EFT_ShopItems_Config.data[itemName] == nil then
                PZ_EFT_ShopItems_Config.AddItem(itemName, {["HIGHVALUE"]=true}, price, 1, 0.5 )
                counter = counter + 1
            end
        end

        if counter > PZ_EFT_CONFIG.Shop.dailyItemsAmount then
            return
        end


    end
end


if isServer() then
    Events.EveryDays.Add(function()
        PZ_EFT_ShopItems_Config.GenerateDailyItems()
        local ServerShopManager = require("ROK/Economy/ServerShopManager")
        local items = ServerShopManager.GetItems()
        sendServerCommand(EFT_MODULES.Shop, "GetShopItems", items)
    end)
end


    