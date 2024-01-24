local KEY_SHOP_ITEMS = "PZ-EFT-SHOP-ITEMS"
local KEY_PVP_INSTANCES = "PZ-EFT-PVP-INSTANCES"
local KEY_PVP_CURRENTINSTANCE = "PZ-EFT-PVP-CURRENTINSTANCE"

----------------------------------------------------------------------------

---@class ClientData
ClientData = ClientData or {}

function ClientData.RequestData()
    ModData.request(KEY_SHOP_ITEMS)
    ModData.request(KEY_PVP_CURRENTINSTANCE)
    ModData.request(KEY_PVP_INSTANCES)
end

function ClientData.OnReceiveGlobalModData(key, modData)
    if key == KEY_SHOP_ITEMS or key == KEY_PVP_CURRENTINSTANCE or key == KEY_PVP_INSTANCES then
        debugPrint("Received modData for " .. key)
        ModData.add(key, modData)
    end

    -- The client has collected the mod data from the server
    triggerEvent("PZEFT_ClientModDataReady", key)
end

Events.OnReceiveGlobalModData.Add(ClientData.OnReceiveGlobalModData)

--------------------------------------

ClientData.PVPInstances = ClientData.PVPInstances or {}

function ClientData.PVPInstances.GetPvpInstances()
    return ModData.getOrCreate(KEY_PVP_INSTANCES)
end

function ClientData.PVPInstances.GetCurrentInstance()
    return ModData.getOrCreate(KEY_PVP_CURRENTINSTANCE)
end

--------------------------------------

ClientData.Shop = ClientData.Shop or {}

function ClientData.Shop.GetShopItems()
    return ModData.getOrCreate(KEY_SHOP_ITEMS)
end

-----------------------------------------------------------------

local ClientDataCommands = {}
local MODULE = EFT_MODULES.Data

---Starts when Server Mod Data is ready, initialize Global Mod Data on the client
function ClientDataCommands.SeverModDataReady()
    ClientData.RequestData()
end

--- Sets pvpInstanceTable
--- Or use ClientCommands.print_pvp_currentinstance() to print current instance on the server's console
---@param instanceData pvpInstanceTable
function ClientDataCommands.SetCurrentInstance(instanceData)
    local md = getPlayer():getModData()
    md.currentInstance = md.currentInstance or {}
    md.currentInstance = instanceData
end

local function OnClientDataCommands(module, command, args)
    if (module == MODULE or module == MODULE) and ClientDataCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        ClientDataCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnClientDataCommands)
