require "ShopItems/PZ_EFT_ShopItems"
require "ROK/ServerData"
------------------------------

---@class ServerShopManager
local ServerShopManager = {}

---Transmit shop items
function ServerShopManager.TransmitShopItems()
    ServerData.Shop.TransmitShopItems()
end

function ServerShopManager.LoadShopPrices()
    local shopItems = ServerData.Shop.GetShopItems()
    shopItems.items = shopItems.items or {}
    shopItems.tags = shopItems.tags or {}
    shopItems.doInitShopItems = true --TODO: Remove, just for testing.
    if shopItems.doInitShopItems then
        shopItems.doInitShopItems = nil
        for i, v in pairs(PZ_EFT_ShopItems_Config.data) do
            shopItems = DoTags(shopItems, i, v)
            shopItems.items[i] = {
                fullType = v.fullType,
                tags = v.tags,
                basePrice = v.basePrice,
                multiplier = v.initialMultiplier,       -- TODO this doesn't work for some reason
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