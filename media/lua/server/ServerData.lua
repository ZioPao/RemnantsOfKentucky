if (not isServer()) and not (not isServer() and not isClient()) then return end

require "PZ_EFT_debugtools"
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

    
    local doInitShopItems = not ModData.exists(KEY_SHOP_ITEMS)
    local data = ModData.getOrCreate(KEY_SHOP_ITEMS)
    data.doInitShopItems = doInitShopItems

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

ServerData.PVPInstances = ServerData.PVPInstances or {}

--- Get table of PVP instances data
---@return Table Of ["cellX-cellY"]={id="cellX-cellY", x=cellx, y=celly, spawnPoints={{...}, {...}}, extractionPoints={{...}}}
ServerData.PVPInstances.GetPvpInstances = function()
    return ModData.getOrCreate(KEY_PVP_INSTANCES)
end

--- Set table of PVP instances data
---@param data Table Of ["cellX-cellY"]={id="cellX-cellY", x=cellx, y=celly, spawnPoints={{...}, {...}}, extractionPoints={{...}}}
ServerData.PVPInstances.SetPvpInstances = function(data)
    ModData.add(KEY_PVP_INSTANCES, data)
end

--- Get table of PVP used instances data
---@return Table Of ["cellX-cellY"]={id="cellX-cellY", x=cellx, y=celly, spawnPoints={{...}, {...}}, extractionPoints={{...}}}
ServerData.PVPInstances.GetPvpUsedInstances = function()
    return ModData.getOrCreate(KEY_PVP_USEDINSTANCES)
end

--- Set table of PVP used instances data
---@param data Table Of ["cellX-cellY"]={id="cellX-cellY", x=cellx, y=celly, spawnPoints={{...}, {...}}, extractionPoints={{...}}}
ServerData.PVPInstances.SetPvpUsedInstances = function(data)
    ModData.add(KEY_PVP_USEDINSTANCES, data)
end

--- Get PVP current instance data
---@return {id="cellX-cellY", x=cellx, y=celly, spawnPoints={{...}, {...}}, extractionPoints={{...}}}
ServerData.PVPInstances.GetPvpCurrentInstance = function()
    return ModData.getOrCreate(KEY_PVP_CURRENTINSTANCE)
end

--- Set PVP current instance data
---@param data {id="cellX-cellY", x=cellx, y=celly, spawnPoints={{...}, {...}}, extractionPoints={{...}}}
ServerData.PVPInstances.SetPvpCurrentInstance = function(data)
    ModData.add(KEY_PVP_CURRENTINSTANCE, data)
end

ServerData.SafehouseInstances = ServerData.SafehouseInstances or {}

--- Get table of safehouse instances
---@return Table Of ["worldx-worldy-worldz"]={x=worldx, y=worldy, z=worldz}
ServerData.SafehouseInstances.GetSafehouseInstances = function()
    return ModData.getOrCreate(KEY_SAFEHOUSE_INSTANCES)
end

--- Set table of safehouse instances
---@param data Table Of ["worldx-worldy-worldz"]={x=worldx, y=worldy, z=worldz}
ServerData.SafehouseInstances.SetSafehouseInstances = function(data)
    ModData.add(KEY_SAFEHOUSE_INSTANCES, data)
end

--- Get table fo assigned instances
---@return Table Of ["worldx-worldy-worldz"]=username
ServerData.SafehouseInstances.GetSafehouseAssignedInstances = function()
    return ModData.getOrCreate(KEY_SAFEHOUSE_ASSIGNEDINSTANCES)
end

--- Set table of assigned instances
---@param data Table Of ["worldx-worldy-worldz"]=username
ServerData.SafehouseInstances.SetSafehouseAssignedInstances = function(data)
    ModData.add(KEY_SAFEHOUSE_ASSIGNEDINSTANCES, data)
end

ServerData.Bank = ServerData.Bank or {}

--- Get table of bank accounts
---@return Table Of ["usernames"]=balance
ServerData.Bank.GetBankAccounts = function()
    return ModData.getOrCreate(KEY_BANK_ACCOUNTS)
end

--- Set table of bank accounts
---@param data Table Of ["usernames"]=balance
ServerData.Bank.SetBankAccounts = function(data)
    ModData.add(KEY_BANK_ACCOUNTS, data)
end

ServerData.Shop = ServerData.Shop or {}

--- Get table of shop items
---@return Table Of ["fulltype"] = {basePrice = basePrice, multiplier = initialMultiplier or 1 }
ServerData.Bank.GetShopItems = function()
    return ModData.getOrCreate(KEY_SHOP_ITEMS)
end

--- Set table of shop items
---@param data Table Of ["fulltype"] = {basePrice = basePrice, multiplier = initialMultiplier or 1 }
ServerData.Bank.SetShopItems = function(data)
    ModData.add(KEY_SHOP_ITEMS, data)
end

--- Transmits table of shop items to clients
ServerData.Bank.TransmitShopItems = function()
    ModData.transmit(KEY_SHOP_ITEMS)
end

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

local function OnServerModDataReady() sendServerCommand("PZEFT", "SeverModDataReady", {}) end

Events.PZEFT_ServerModDataReady.Add(OnServerModDataReady)