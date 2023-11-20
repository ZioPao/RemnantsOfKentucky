if (not isServer()) and not (not isServer() and not isClient()) and not isCoopHost() then return end

require("ROK/DebugTools")
LuaEventManager.AddEvent("PZEFT_ServerModDataReady")

local PZ_EFT = "PZ-EFT"
local KEY_PVP_INSTANCES = "PZ-EFT-PVP-INSTANCES"
local KEY_PVP_USEDINSTANCES = "PZ-EFT-PVP-USEDINSTANCES"
local KEY_PVP_CURRENTINSTANCE = "PZ-EFT-PVP-CURRENTINSTANCE"
local KEY_SAFEHOUSE_INSTANCES = "PZ-EFT-SAFEHOUSE-INSTANCES"
local KEY_SAFEHOUSE_ASSIGNEDINSTANCES = "PZ-EFT-SAFEHOUSE-ASSIGNEDINSTANCES"
local KEY_BANK_ACCOUNTS = "PZ-EFT-BANK-ACCOUNTS"
local KEY_SHOP_ITEMS = "PZ-EFT-SHOP-ITEMS"

ServerData = ServerData or {}

ServerData.Data = {}

ServerData.GlobalModDataInit = function(isNewGame)
    ModData.getOrCreate(KEY_PVP_INSTANCES)
    ModData.getOrCreate(KEY_PVP_USEDINSTANCES)
    ModData.getOrCreate(KEY_PVP_CURRENTINSTANCE)
    ModData.getOrCreate(KEY_SAFEHOUSE_INSTANCES)
    ModData.getOrCreate(KEY_SAFEHOUSE_ASSIGNEDINSTANCES)
    ModData.getOrCreate(KEY_BANK_ACCOUNTS)

    local doInitShopItems = true

    if ModData.exists(KEY_SHOP_ITEMS) then
        doInitShopItems = false
    end

    local data = ModData.getOrCreate(KEY_SHOP_ITEMS)
    data.doInitShopItems = doInitShopItems
    if data.doInitShopItems then
        ServerShopManager.loadShopPrices()
    end

    if not isNewGame then triggerEvent("PZEFT_ServerModDataReady") end
end

Events.OnInitGlobalModData.Add(ServerData.GlobalModDataInit)

ServerData.ClearAllData = function(state)
    ModData.remove(KEY_PVP_INSTANCES)
    ModData.remove(KEY_PVP_USEDINSTANCES)
    ModData.remove(KEY_PVP_CURRENTINSTANCE)
    ModData.remove(KEY_SAFEHOUSE_INSTANCES)
    ModData.remove(KEY_SAFEHOUSE_ASSIGNEDINSTANCES)
    ModData.remove(KEY_BANK_ACCOUNTS)
    ModData.remove(KEY_SHOP_ITEMS)

    ServerData.GlobalModDataInit(state)
end

------------------------------------------------

ServerData.PVPInstances = ServerData.PVPInstances or {}

--- Get table of PVP instances data
---@return pvpInstanceTable
ServerData.PVPInstances.GetPvpInstances = function()
    return ModData.getOrCreate(KEY_PVP_INSTANCES)
end

--- Set table of PVP instances data
---@param data pvpInstanceTable
ServerData.PVPInstances.SetPvpInstances = function(data)
    ModData.add(KEY_PVP_INSTANCES, data)
end

--- Get table of PVP used instances data
---@return pvpInstanceTable
ServerData.PVPInstances.GetPvpUsedInstances = function()
    return ModData.getOrCreate(KEY_PVP_USEDINSTANCES)
end

--- Set table of PVP used instances data
---@param data pvpInstanceTable
ServerData.PVPInstances.SetPvpUsedInstances = function(data)
    ModData.add(KEY_PVP_USEDINSTANCES, data)
end

--- Get PVP current instance data
---@return pvpInstanceTable
ServerData.PVPInstances.GetPvpCurrentInstance = function()
    return ModData.getOrCreate(KEY_PVP_CURRENTINSTANCE)
end

--- Set PVP current instance data
---@param data pvpInstanceTable
ServerData.PVPInstances.SetPvpCurrentInstance = function(data, doTransmit)
    ModData.add(KEY_PVP_CURRENTINSTANCE, data)

    if doTransmit then
        ModData.transmit(KEY_PVP_CURRENTINSTANCE)
    end
end

------------------------------------------------
---@alias worldStringCoords string worldx-worldy-worldz
---@alias safehouseInstancesTable table<worldStringCoords, coords>

ServerData.SafehouseInstances = ServerData.SafehouseInstances or {}

--- Get table of safehouse instances
---@return safehouseInstancesTable
ServerData.SafehouseInstances.GetSafehouseInstances = function()
    return ModData.getOrCreate(KEY_SAFEHOUSE_INSTANCES)
end

--- Set table of safehouse instances
---@param data safehouseInstancesTable
ServerData.SafehouseInstances.SetSafehouseInstances = function(data)
    ModData.add(KEY_SAFEHOUSE_INSTANCES, data)
end

--- Get table fo assigned instances
---@return safehouseInstancesTable
ServerData.SafehouseInstances.GetSafehouseAssignedInstances = function()
    return ModData.getOrCreate(KEY_SAFEHOUSE_ASSIGNEDINSTANCES)
end

--- Set table of assigned instances
---@param data safehouseInstancesTable
ServerData.SafehouseInstances.SetSafehouseAssignedInstances = function(data)
    ModData.add(KEY_SAFEHOUSE_ASSIGNEDINSTANCES, data)
end

------------------------------------------------
---@alias username string
---@alias balance number
---@alias bankAccountsTable table<username, balance>

ServerData.Bank = ServerData.Bank or {}

--- Get table of bank accounts
---@return bankAccountsTable
ServerData.Bank.GetBankAccounts = function()
    return ModData.getOrCreate(KEY_BANK_ACCOUNTS)
end

--- Set table of bank accounts
---@param data bankAccountsTable
ServerData.Bank.SetBankAccounts = function(data)
    ModData.add(KEY_BANK_ACCOUNTS, data)
end

------------------------------------------------
---@alias shopItem {basePrice : number, multiplier : number}        -- multiplier by default 1
---@alias itemFullType string FullType of the item
---@alias shopItemsTable table<itemFullType,shopItem>       -- Key will be full type of the item

ServerData.Shop = ServerData.Shop or {}

--- Get table of shop items
---@return shopItemsTable
ServerData.Shop.GetShopItems = function()
    return ModData.getOrCreate(KEY_SHOP_ITEMS)
end

--- Set table of shop items
---@param data shopItemsTable
ServerData.Shop.SetShopItems = function(data)
    ModData.add(KEY_SHOP_ITEMS, data)
end

--- Transmits table of shop items to clients
ServerData.Shop.TransmitShopItems = function()
    ModData.transmit(KEY_SHOP_ITEMS)
end
------------------------------------------------


ServerData.debug = ServerData.debug or {}

ServerData.debug.print_pvp_instances = function()
    local data = ModData.getOrCreate(KEY_PVP_INSTANCES)
    PZEFT_UTILS.PrintTable(data)
end

ServerData.debug.print_pvp_usedinstances = function()
    local data = ModData.getOrCreate(KEY_PVP_USEDINSTANCES)
    PZEFT_UTILS.PrintTable(data)
end

ServerData.debug.print_pvp_currentinstance = function()
    local data = ModData.getOrCreate(KEY_PVP_CURRENTINSTANCE)
    PZEFT_UTILS.PrintTable(data)
end

ServerData.debug.print_safehouses = function()
    local data = ModData.getOrCreate(KEY_SAFEHOUSE_INSTANCES)
    PZEFT_UTILS.PrintTable(data)
end

ServerData.debug.print_assignedsafehouses = function()
    local data = ModData.getOrCreate(KEY_SAFEHOUSE_ASSIGNEDINSTANCES)
    PZEFT_UTILS.PrintTable(data)
end

ServerData.debug.print_bankaccounts = function()
    local data = ModData.getOrCreate(KEY_BANK_ACCOUNTS)
    PZEFT_UTILS.PrintTable(data)
end

ServerData.debug.print_shopitems = function()
    local data = ModData.getOrCreate(KEY_SHOP_ITEMS)
    PZEFT_UTILS.PrintTable(data)
end

------------------------------------------------

local function OnServerModDataReady() sendServerCommand("PZEFT", "SeverModDataReady", {}) end

Events.PZEFT_ServerModDataReady.Add(OnServerModDataReady)