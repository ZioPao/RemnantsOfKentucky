require "PZ_EFT_debugtools"

--TODO: TEST EVERYTHING
-- This might be overengineered a bit lmao
-- Tried to keep an API structure where we "request" global mod data through these functions

local PZ_EFT = "PZ-EFT"
local KEY_PVP_INSTANCES = "PZ-EFT-PVP-INSTANCES"
local KEY_PVP_USEDINSTANCES = "PZ-EFT-PVP-USEDINSTANCES"
local KEY_PVP_CURRENTINSTANCE = "PZ-EFT-PVP-CURRENTINSTANCE"

local KEY_SAFEHOUSE_INSTANCES = "PZ-EFT-SAFEHOUSE-INSTANCES"
local KEY_SAFEHOUSE_ASSIGNEDINSTANCES = "PZ-EFT-SAFEHOUSE-ASSIGNEDINSTANCES"

local KEY_BANK_ACCOUNTS = "PZ-EFT-BANK-ACCOUNTS"

ServerData = ServerData or {}

ServerData.Data = {}

local function getOrCreateModData(key)
    local baseData = ModData.getOrCreate(PZ_EFT)
    PZEFT_UTILS.PrintTable(baseData)
    baseData[key] = baseData[key] or {}
    return baseData[key]
end

local function getData(key)
    --TODO: TEST THAT DATA STAYS SYNCED
    debugPrint("ServerData.Data["..key.."]")
    PZEFT_UTILS.PrintTable(ServerData.Data[key])
    debugPrint("getOrCreateData("..key..")")
    PZEFT_UTILS.PrintTable(getOrCreateData(key))

    return ServerData.Data[key] or getOrCreateData(key)
end

--TODO: AFAIK everything is done by reference so if we update something in ServerData.Data, it gets updated in OnInitGlobalModData?
--- Load data in a local variable
ServerData.LoadData = function()
    ServerData.Data[KEY_PVP_INSTANCES] = ServerData.PVPInstances.GetPvpInstances()
    ServerData.Data[KEY_PVP_USEDINSTANCES] = ServerData.PVPInstances.GetPvpCurrentInstance()
    ServerData.Data[KEY_PVP_CURRENTINSTANCE] = ServerData.PVPInstances.GetPvpUsedInstances()

    ServerData.Data[KEY_SAFEHOUSE_INSTANCES] = ServerData.SafehouseInstances.GetSafehouseInstances()
    ServerData.Data[KEY_SAFEHOUSE_ASSIGNEDINSTANCES] = ServerData.SafehouseInstances.GetSafehouseAssignedInstances()

    ServerData.Data[KEY_BANK_ACCOUNTS] = ServerData.Bank.GetBankAccounts()
end

ServerData.PVPInstances = ServerData.PVPInstances or {}

--- Get table of PVP instances data
---@return Table Of ["cellX-cellY"]={id="cellX-cellY", x=cellx, y=celly, spawnPoints={{...}, {...}}, extractionPoints={{...}}}
ServerData.PVPInstances.GetPvpInstances = function()
    return getData(KEY_PVP_INSTANCES)
end

--- Set table of PVP instances data
---@param data Table Of ["cellX-cellY"]={id="cellX-cellY", x=cellx, y=celly, spawnPoints={{...}, {...}}, extractionPoints={{...}}}
ServerData.PVPInstances.SetPvpInstances = function(data)
    local gmd = getData(KEY_PVP_INSTANCES)
    gmd = data
end

--- Get table of PVP used instances data
---@return Table Of ["cellX-cellY"]={id="cellX-cellY", x=cellx, y=celly, spawnPoints={{...}, {...}}, extractionPoints={{...}}}
ServerData.PVPInstances.GetPvpUsedInstances = function()
    return getData(KEY_PVP_USEDINSTANCES)
end

--- Set table of PVP used instances data
---@param data Table Of ["cellX-cellY"]={id="cellX-cellY", x=cellx, y=celly, spawnPoints={{...}, {...}}, extractionPoints={{...}}}
ServerData.PVPInstances.SetPvpUsedInstances = function(data)
    local gmd = getData(KEY_PVP_USEDINSTANCES)
    gmd = data
end

--- Get PVP current instance data
---@return {id="cellX-cellY", x=cellx, y=celly, spawnPoints={{...}, {...}}, extractionPoints={{...}}}
ServerData.PVPInstances.GetPvpCurrentInstance = function()
    return getData(KEY_PVP_CURRENTINSTANCE)
end

--- Set PVP current instance data
---@param data {id="cellX-cellY", x=cellx, y=celly, spawnPoints={{...}, {...}}, extractionPoints={{...}}}
ServerData.PVPInstances.SetPvpCurrentInstance = function(data)
    local gmd = getData(KEY_PVP_CURRENTINSTANCE)
    gmd = data
end

ServerData.SafehouseInstances = ServerData.SafehouseInstances or {}

--- Get table of safehouse instances
---@return Table Of ["worldx-worldy-worldz"]={x=worldx, y=worldy, z=worldz}
ServerData.SafehouseInstances.GetSafehouseInstances = function()
    return getData(KEY_SAFEHOUSE_INSTANCES)
end

--- Set table of safehouse instances
---@param data Table Of ["worldx-worldy-worldz"]={x=worldx, y=worldy, z=worldz}
ServerData.SafehouseInstances.SetSafehouseInstances = function(data)
    local gmd = getData(KEY_SAFEHOUSE_INSTANCES)
    gmd = data
end

--- Get table fo assigned instances
---@return Table Of ["worldx-worldy-worldz"]=username
ServerData.SafehouseInstances.GetSafehouseAssignedInstances = function()
    return getData(KEY_SAFEHOUSE_ASSIGNEDINSTANCES)
end

--- Set table of assigned instances
---@param data Table Of ["worldx-worldy-worldz"]=username
ServerData.SafehouseInstances.SetSafehouseAssignedInstances = function(data)
    local gmd = getData(KEY_SAFEHOUSE_ASSIGNEDINSTANCES)
    gmd = data
end

ServerData.Bank = ServerData.Bank or {}

--- Get table of bank accounts
---@return Table Of ["usernames"]=balance
ServerData.Bank.GetBankAccounts = function()
    return getData(KEY_BANK_ACCOUNTS)
end

--- Set table of bank accounts
---@param data Table Of ["usernames"]=balance
ServerData.Bank.SetBankAccounts = function(data)
    local gmd = getData(KEY_BANK_ACCOUNTS)
    gmd = data
end

Events.OnInitGlobalModData.Add(ServerData.LoadData)