---@class ShopItems
local ShopItemsManager = {}
ShopItemsManager.data = {}

---@alias shopTags table 

---@alias shopItemElement {fullType : string, tag : string, basePrice : number, multiplier : number, sellMultiplier : number, quantity : number?}

--- Add shop item
---@param fullType itemFullType
---@param tag string
---@param basePrice integer
function ShopItemsManager.AddItem(fullType, tag, basePrice)
    ShopItemsManager.data[fullType] = {fullType = fullType, tag = tag, basePrice = basePrice, multiplier = 1, sellMultiplier =  0.5 }
end

function ShopItemsManager.SetTagToItem(fullType, tag)
    ShopItemsManager.data[fullType].tag = tag
end

---@param fullType string
---@return shopItemElement
function ShopItemsManager.GetItem(fullType)
    ---@type shopItemElement
    local itemData = ShopItemsManager.data[fullType]

    if itemData == nil then
        -- Cache it
        ShopItemsManager.AddItem(fullType, "", 100)
        itemData = ShopItemsManager.data[fullType]
    end

    return itemData
end



---------------------------------------------
--* Sell Stuff

---@alias sellData table<integer, {itemData : shopItemElement, quantity : number, quality : number}>

--- ItemsList is coming from the ScrollingListBox, we need to keep track of quality stuff so that's why we need groups of every single item
---@param itemsList table<integer, {item : table<integer, InventoryItem>}>
---@return sellData
function ShopItemsManager.StructureSellData(itemsList)
    -- Cycle through the items and structure them in the correct way
    local structuredData = {}
     for i=1, #itemsList do
         local quality = 1
         local genericItem = itemsList[i].item[1]
         local fullType = genericItem:getFullType()
         local quantity = #itemsList[i].item

         local isDrainable = ScriptManager.instance:isDrainableItemType(fullType)
         local isClothing = instanceof(genericItem, "IsoClothing")

         if isDrainable or isClothing then
            quality = 0
            for j=1, #itemsList[i].item do
                local item = itemsList[i].item[j]

                if isDrainable then
                    quality = quality + item:getUsedDelta()
                elseif isClothing then
                    quality = quality + item:getCondition()
                end
            end
            quality = quality / quantity            -- mean
            debugPrint(quality)

         end

         local itemData = ShopItemsManager.GetItem(fullType)
         table.insert(structuredData, {itemData = itemData, quantity = quantity, quality = quality})
     end

     return structuredData
 end


-----------------------------------------

if isServer() then

    local json = require("ROK/JSON")

    ---load prices from a JSON
    function ShopItemsManager.LoadData()

        -- Load default JSON, if there's no custom one in the cachedir
        local fileName = PZ_EFT_CONFIG.Shop.jsonName
        local readData = json.readFile(fileName)

        -- Check if is blank or not
        if not readData then
            local writer = getFileWriter(fileName, true, false)
            local itemsStr = json.readModFile('ROK', 'media/data/default_prices.json')
            writer:write(itemsStr)
            writer:close()

            -- get data again
            readData = json.readFile(fileName)
        end

        local parsedData = json.parse(readData)


        local allItems = getScriptManager():getAllItems()
        for i=0, allItems:size() - 1 do

            ---@type Item
            local item = allItems:get(i)

            local fullType = item:getModuleName() .. "." .. item:getName()

            if parsedData[fullType] then
                local data = parsedData[fullType]
                ShopItemsManager.AddItem(data.fullType, data.tag, data.basePrice)
            else
                ShopItemsManager.AddItem(fullType, "VARIOUS", 100)
            end


        -- for k,v in pairs(parsedData) do
        --     --debugPrint(k)
        --     local fullType = v.fullType
        --     --debugPrint(fullType)
        --     local tag = v.tag
        --     local basePrice = v.basePrice
        --     ShopItemsManager.AddItem(fullType, tag, basePrice)

        -- end


    end


    ---@param itemsData table<integer, {fullType : string, tag : string, basePrice : number}>
    function ShopItemsManager.OverwriteData(itemsData)
        local stringifiedData = json.stringify(itemsData)
        local writer = getFileWriter(PZ_EFT_CONFIG.Shop.jsonName, true, false)
        writer:write(stringifiedData)
        writer:close()
    end

    local function GetKeys(t)
        local t2 = {}
        --PZEFT_UTILS.PrintTable(t)

        for key, _ in pairs(t) do
            table.insert(t2, key)
        end

        return t2
      end

    ---@param percentage number
    ---@param items any
    ---@param tag string
    local function FetchNRandomItems(percentage, items, tag)
        local amount = math.floor(PZ_EFT_CONFIG.Shop.dailyItemsAmount * (percentage/100))

        debugPrint("Adding " .. tostring(amount) .." for " .. tag)
        local currentAmount = 0

        -- We want to pop stuff from here
        local keys = GetKeys(items.tags[tag])
        --PZEFT_UTILS.PrintTable(keys)

        while currentAmount < amount do
            local randIndex = ZombRand(#keys) + 1
            local fType = keys[randIndex]   -- FIX Can cause issue
            debugPrint("Adding to daily: fType=" .. fType)

            -- Check if Item actually exists, in case mod wasn't loaded
            local item = InventoryItemFactory.CreateItem(fType)
            if item then
                ShopItemsManager.SetTagToItem(fType, "DAILY")
                currentAmount = currentAmount + 1
            end
            table.remove(keys, randIndex)

        end
    end

    --- At startup and at every new day
    function ShopItemsManager.GenerateDailyItems()
        debugPrint("Generating daily items")

        -- for _,v in pairs(ShopItemsManager.data) do
        -- ---@cast v shopItemElement

        --     local fType = v.fullType
        --     ShopItemsManager.SetTagToItem(fType, "DAILY", false)

        -- end
        local items = ServerData.Shop.GetShopItemsData()


        -- Should stack to 100%
        FetchNRandomItems(20, items, 'WEAPON')
        FetchNRandomItems(5, items, 'TOOL')
        FetchNRandomItems(15, items, "MILITARY_CLOTHING")
        FetchNRandomItems(10, items, "CLOTHING")
        FetchNRandomItems(5, items, "SKILL_BOOK")
        FetchNRandomItems(15, items, "FURNITURE")
        FetchNRandomItems(5, items, "FIRST_AID")
        FetchNRandomItems(5, items, "FOOD")
        FetchNRandomItems(20, items, "VARIOUS")
    end


end


return ShopItemsManager