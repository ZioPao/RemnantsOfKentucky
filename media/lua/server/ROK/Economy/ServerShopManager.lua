if not isServer() then return end
require "ShopItems/PZ_EFT_ShopItems"
------------------------------

---@class ServerShopManager
local ServerShopManager = {}

---Transmit shop items
function ServerShopManager.TransmitShopItems()
    ServerData.Shop.TransmitShopItems()
end

---@param shopItems any
---@param id any
---@param item any
---@return table
local function DoTags(shopItems, id, item)
    if item.tags["JUNK"] then
        shopItems.tags["JUNK"] = shopItems.tags["JUNK"] or {}
        shopItems.tags["JUNK"][id] = true
    end

    if item.tags["ESSENTIALS"] then
        shopItems.tags["ESSENTIALS"] = shopItems.tags["ESSENTIALS"] or {}
        shopItems.tags["ESSENTIALS"][id] = true
    end

    if item.tags["HIGHVALUE"] then
        shopItems.tags["HIGHVALUE"] = shopItems.tags["HIGHVALUE"] or {}
        shopItems.tags["HIGHVALUE"][id] = true
    end

    if item.tags["LOWVALUE"] then
        shopItems.tags["LOWVALUE"] = shopItems.tags["LOWVALUE"] or {}
        shopItems.tags["LOWVALUE"][id] = true
    end
    return shopItems
end


function ServerShopManager.LoadShopPrices()
    -- TODO Refactor this as a whole
    local shopItems = ServerData.Shop.GetShopItems()
    shopItems.items = shopItems.items or {}
    shopItems.tags = shopItems.tags or {}
    shopItems.doInitShopItems = true
    if shopItems.doInitShopItems then
        shopItems.doInitShopItems = nil
        for i, v in pairs(PZ_EFT_ShopItems_Config.data) do
            shopItems = DoTags(shopItems, i, v)
            shopItems.items[i] = {
                fullType = v.fullType,
                tags = v.tags,
                basePrice = v.basePrice,
                multiplier = v.initialMultiplier,
                sellMultiplier = v.sellMultiplier
            }
            --PZEFT_UTILS.PrintTable(shopItems.items[i])
        end
    end

    ServerData.Shop.TransmitShopItems()
end

Events.PZEFT_ServerModDataReady.Add(ServerShopManager.LoadShopPrices)

------------------------------------------------------------------------
--* COMMANDS FROM CLIENTS *--
------------------------------------------------------------------------

local ShopCommands = {}

--- Receive updated shop item list from admin client and transmit it back to all clients
---@param data any
function ShopCommands.TransmitShopItems(_, data)
    ServerData.Shop.SetShopItems(data)
    ServerData.Shop.TransmitShopItems()
end

------------------------------------

function OnShopCommand(module, command, playerObj, args)
    if module == EFT_MODULES.Shop and ShopCommands[command] then
        debugPrint("Client Command - " .. EFT_MODULES.Shop .. "." .. command)
        ShopCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnShopCommand)



return ServerShopManager