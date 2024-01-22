local ClientState = require("ROK/ClientState")
local LoadingScreen = require("ROK/UI/LoadingScreen")
local ClientBankManager = require("ROK/Economy/ClientBankManager")
local Delay = require("ROK/Delay")
-----------------------------
local CratesHandling = {}


--* Startup handling

--- On player initialise, request safehouse allocation of player from server
local function OnPlayerInit()
    debugPrint("Initializing player")
    LoadingScreen.Open()

    Delay.Initialize()

    -- Zomboid is a huge piece of shit. We can't use sendClientCommand right after player init since the player isn't actually in game.
    -- Huge workaround, but just delay this function to run 2 seconds after the player  has been "created".
    Delay:set(2, function()
        --* Safehouse handling
        -- Request safe house allocation (or just teleport, if it was already done), which in turn will teleport the player to the assigned safehouse
        sendClientCommand(EFT_MODULES.Safehouse, "RequestSafehouseAllocation", {teleport = true})

        --* Shop Items
        debugPrint("Requesting TransmitShopItems to the client now that player is in")
        sendClientCommand(EFT_MODULES.Shop, 'TransmitShopItems', {})

        --* Request bank account 
        --sendClientCommand(EFT_MODULES.Bank, 'UpdateCratesValue', {})
        CratesHandling.ToggleContainersValueUpdate(false)

        --* Clean map
        ISWorldMap.HandleEFTExits(true)

        --* Force delete zombies while in safehouse (to prevent issues)
        

        LoadingScreen.Close()
    end)

    Events.OnPlayerUpdate.Remove(OnPlayerInit)
end


Events.OnPlayerUpdate.Add(OnPlayerInit)


--* Raid handling

-- If player in raid, set that they're not in it anymore
local function OnPlayerExit()
    if ClientState.GetIsInRaid() == false then return end

    sendClientCommand(EFT_MODULES.Match, "RemovePlayer", {})

    if isAdmin() then
        --Forcefully close Admin Panel
        local BeforeMatchAdminPanel = require("ROK/UI/BeforeMatch/BeforeMatchAdminPanel")
        local DuringMatchAdminPanel = require("ROK/UI/DuringMatch/DuringMatchAdminPanel")
        BeforeMatchAdminPanel.OnClosePanel()
        DuringMatchAdminPanel.OnClosePanel()
    end

    -- Close Time Panel
    local TimePanel = require("ROK/UI/TimePanel")
    TimePanel.Close()

    -- -- Reset buttons 
    -- ButtonManager.Reset()
end

Events.OnPlayerDeath.Add(OnPlayerExit)
Events.OnDisconnect.Add(OnPlayerExit)


--* Crates handling


function CratesHandling.UpdateContainersValue()
    -- TODO Stupid heavy, figure out a better way to check when a container status changes instead of this crap
    --sendClientCommand(EFT_MODULES.Bank, 'UpdateCratesValue', {})
    --debugPrint("Update containers value, requesting bank account again")
    ClientBankManager.RequestBankAccountFromServer(true)

end

---comment
---@param isInRaid boolean
function CratesHandling.ToggleContainersValueUpdate(isInRaid)
    debugPrint("Toggling UpdateCratesValue")

    if not isInRaid then
        Events.EveryOneMinute.Remove(CratesHandling.UpdateContainersValue)
        Events.EveryOneMinute.Add(CratesHandling.UpdateContainersValue)
    else
        Events.EveryOneMinute.Remove(CratesHandling.UpdateContainersValue)
    end
end



Events.PZEFT_UpdateClientStatus.Add(CratesHandling.ToggleContainersValueUpdate)