---@class ShopItems
local ShopItemsManager = {}
ShopItemsManager.data = {}

---@alias shopTags table  [JUNK, ESSENTIALS, HIGHVALUE, LOWVALUE]

---@alias shopItemElement {fullType : string, tags : shopTags, basePrice : number, multiplier : number, sellMultiplier : number, quantity : number?}

--- Add shop item
---@param fullType itemFullType
---@param tags shopTags
---@param basePrice integer
---@param initialMultiplier integer
---@param sellMultiplier integer
function ShopItemsManager.AddItem(fullType, tags, basePrice, initialMultiplier, sellMultiplier)
    ShopItemsManager.data[fullType] = {fullType = fullType, tags = tags, basePrice = basePrice, multiplier = initialMultiplier or 1, sellMultiplier = sellMultiplier or 1 }
end

---@param fullType string
---@return shopItemElement
function ShopItemsManager.GetItem(fullType)
    ---@type shopItemElement
    local itemData = ShopItemsManager.data[fullType]

    if itemData == nil then
        -- Cache it
        ShopItemsManager.AddItem(fullType, {}, 100, 1, 0.5)
        itemData = ShopItemsManager.data[fullType]
    end

    return itemData
end

--- At startup and at every new day
function ShopItemsManager.GenerateDailyItems()
    -- Clean old Daily Items
    debugPrint("Generating daily items")

    for k,v in pairs(ShopItemsManager.data) do
    ---@cast v shopItemElement

        if v.tags.HIGHVALUE then
            ShopItemsManager.data[k] = nil
        end
    end


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

            if ShopItemsManager.data[itemName] == nil then
                ShopItemsManager.AddItem(itemName, {["HIGHVALUE"]=true}, price, 1, 0.5 )
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
        ShopItemsManager.GenerateDailyItems()
        local ServerShopManager = require("ROK/Economy/ServerShopManager")
        local items = ServerShopManager.GetItems()
        sendServerCommand(EFT_MODULES.Shop, "GetShopItems", items)
    end)


    ShopItemsManager.AddItem("Base.GranolaBar", {["ESSENTIALS"] = true}, 20, 1, 0.5)
    ShopItemsManager.AddItem("Base.WaterBottleFull", {["ESSENTIALS"] = true}, 50, 1, 0.5)
    ShopItemsManager.AddItem("Base.Cereal", {["ESSENTIALS"] = true}, 20, 1, 0.5)
    ShopItemsManager.AddItem("Base.Butter", {["ESSENTIALS"] = true}, 500, 1, 0.5)
    ShopItemsManager.AddItem("Base.BaseballBat", {["ESSENTIALS"] = true}, 200, 1, 0.5)
    ShopItemsManager.AddItem("Base.Crowbar", {["ESSENTIALS"] = true}, 1000, 1, 0.5)
    ShopItemsManager.AddItem("Base.ShotgunSawnoff", {["ESSENTIALS"] = true}, 1500, 1, 0.5)
    ShopItemsManager.AddItem("Base.ShotgunShellsBox", {["ESSENTIALS"] = true}, 250, 1, 0.5)
    ShopItemsManager.AddItem("Base.Pistol", {["ESSENTIALS"] = true}, 750, 1, 0.5)
    ShopItemsManager.AddItem("Base.9mmClip", {["ESSENTIALS"] = true}, 250, 1, 0.5)
    ShopItemsManager.AddItem("Base.Bullets9mmBox", {["ESSENTIALS"] = true}, 250, 1, 0.5)
    ShopItemsManager.AddItem("Base.Bandage", {["ESSENTIALS"] = true}, 100, 1, 0.5)
    ShopItemsManager.AddItem("ROK.InstaHeal", {["ESSENTIALS"] = true}, 2500, 1, 0.5)

    -------------------------

    ShopItemsManager.GenerateDailyItems()

end


return ShopItemsManager