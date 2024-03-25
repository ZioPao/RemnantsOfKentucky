if not isServer() then return end

require("ROK/DebugTools")
------------------------

local KEY_PVP_USEDINSTANCES = "PZ-EFT-PVP-USEDINSTANCES"
local KEY_SAFEHOUSE_INSTANCES = "PZ-EFT-SAFEHOUSE-INSTANCES"
local KEY_SAFEHOUSE_ASSIGNEDINSTANCES = "PZ-EFT-SAFEHOUSE-ASSIGNEDINSTANCES"
local KEY_BANK_ACCOUNTS = "PZ-EFT-BANK-ACCOUNTS"

ServerData = ServerData or {}

ServerData.Data = {}

---We can't use isNewGame parameter since it's client only, from what I understand
function ServerData.GlobalModDataInit()
    debugPrint("Starting Global Mod Data Init")
    ModData.getOrCreate(EFT_ModDataKeys.PVP_INSTANCES)
    ModData.getOrCreate(KEY_PVP_USEDINSTANCES)
    ModData.getOrCreate(EFT_ModDataKeys.PVP_CURRENT_INSTANCE_ID)
    ModData.getOrCreate(KEY_SAFEHOUSE_INSTANCES)
    ModData.getOrCreate(KEY_SAFEHOUSE_ASSIGNEDINSTANCES)
    ModData.getOrCreate(KEY_BANK_ACCOUNTS)
    ModData.getOrCreate(EFT_ModDataKeys.SHOP_ITEMS)
    ModData.getOrCreate(EFT_ModDataKeys.PLAYERS)

    triggerEvent("PZEFT_ServerModDataReady")
end

Events.OnInitGlobalModData.Add(ServerData.GlobalModDataInit)

function ServerData.ClearAllData()
    ModData.remove(EFT_ModDataKeys.PVP_INSTANCES)
    ModData.remove(KEY_PVP_USEDINSTANCES)
    ModData.remove(EFT_ModDataKeys.PVP_CURRENT_INSTANCE_ID)
    ModData.remove(KEY_SAFEHOUSE_INSTANCES)
    ModData.remove(KEY_SAFEHOUSE_ASSIGNEDINSTANCES)
    ModData.remove(KEY_BANK_ACCOUNTS)
    ModData.remove(EFT_ModDataKeys.SHOP_ITEMS)
    ModData.remove(EFT_ModDataKeys.PLAYERS)

    ServerData.GlobalModDataInit()
end

------------------------------------------------

ServerData.PVPInstances = ServerData.PVPInstances or {}

--- Get table of PVP instances data
---@return pvpInstanceTable
ServerData.PVPInstances.GetPvpInstances = function()
    return ModData.getOrCreate(EFT_ModDataKeys.PVP_INSTANCES)
end

--- Set table of PVP instances data
---@param data pvpInstanceTable
ServerData.PVPInstances.SetPvpInstances = function(data)
    ModData.add(EFT_ModDataKeys.PVP_INSTANCES, data)
end

--- Get table of PVP used instances data
---@return table<string, boolean>
ServerData.PVPInstances.GetPvpUsedInstances = function()
    return ModData.getOrCreate(KEY_PVP_USEDINSTANCES)
end

--- Set table of PVP used instances data
---@param data table<string, boolean>       id and if it's used or not
ServerData.PVPInstances.SetPvpUsedInstances = function(data)
    ModData.add(KEY_PVP_USEDINSTANCES, data)
end

--- Get PVP current instance data
---@return pvpInstanceTable
ServerData.PVPInstances.GetPvpCurrentInstance = function()
    return ModData.getOrCreate(EFT_ModDataKeys.PVP_CURRENT_INSTANCE_ID)
end

--- Set PVP current instance data
---@param data pvpInstanceTable
function ServerData.PVPInstances.SetPvpCurrentInstance(data)
    ModData.add(EFT_ModDataKeys.PVP_CURRENT_INSTANCE_ID, data)
end

function ServerData.PVPInstances.TransmitPvpCurrentInstance()
    ModData.transmit(EFT_ModDataKeys.PVP_CURRENT_INSTANCE_ID)
end
------------------------------------------------
---@alias worldStringCoords string worldx-worldy-worldz
---@alias assignedSafehousesTable table<worldStringCoords, string>      value is username
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
---@return assignedSafehousesTable
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
---@alias bankPlayerTable {username : string, balance : number, cratesValue : number}
---@alias bankAccountsTable table<username, bankPlayerTable>

--* BANK - SERVER DATA *--
ServerData.Bank = ServerData.Bank or {}

--- Get table of bank accounts
---@return bankAccountsTable
function ServerData.Bank.GetBankAccounts()
    return ModData.getOrCreate(KEY_BANK_ACCOUNTS)
end

--- Set table of bank accounts
---@param data bankAccountsTable
function ServerData.Bank.SetBankAccounts(data)
    ModData.add(KEY_BANK_ACCOUNTS, data)
end

------------------------------------------------
---@alias itemFullType string FullType of the item
---@alias shopItemsTable { items : table<string, shopItemElement>, tags: table<string, table<integer,boolean>> }


--* SHOP - SERVER DATA *--
ServerData.Shop = ServerData.Shop or {}

--- Get table of shop items
---@return shopItemsTable
function ServerData.Shop.GetShopItemsData()
    return ModData.getOrCreate(EFT_ModDataKeys.SHOP_ITEMS)
end

--- Transmits table of shop items to clients, !!!!!!DEBUG ONLY!!!!!
function ServerData.Shop.TransmitShopItemsData()
    ModData.transmit(EFT_ModDataKeys.SHOP_ITEMS)
end
------------------------------------------------


--* PLAYERS MISSING IN ACTION - SERVER DATA *--
ServerData.Players = ServerData.Players or {}

-- { username : { table of booleans that can be sent to client maybe}}

---@alias PlayersDataType table<string, {isMIA : boolean}>

---@return PlayersDataType
function ServerData.Players.GetPlayersData()
    return ModData.getOrCreate(EFT_ModDataKeys.PLAYERS)
end

function ServerData.Players.SetPlayersData(data)
    ModData.add(EFT_ModDataKeys.PLAYERS, data)
end

function ServerData.Shop.TransmitPlayersData()
    ModData.transmit(EFT_ModDataKeys.PLAYERS)
end

------------------------------------------------



ServerData.debug = ServerData.debug or {}

ServerData.debug.print_pvp_instances = function()
    local data = ModData.getOrCreate(EFT_ModDataKeys.PVP_INSTANCES)
    PZEFT_UTILS.PrintTable(data)
end

ServerData.debug.print_pvp_usedinstances = function()
    local data = ModData.getOrCreate(KEY_PVP_USEDINSTANCES)
    PZEFT_UTILS.PrintTable(data)
end

ServerData.debug.print_pvp_currentinstance = function()
    local data = ModData.getOrCreate(EFT_ModDataKeys.PVP_CURRENT_INSTANCE_ID)
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
    local data = ModData.getOrCreate(EFT_ModDataKeys.SHOP_ITEMS)
    PZEFT_UTILS.PrintTable(data)
end

