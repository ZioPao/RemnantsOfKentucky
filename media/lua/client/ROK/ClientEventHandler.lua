local ClientState = require("ROK/ClientState")
-----------------------------
local CratesHandling = {}


--* Startup handling


--- On player initialise, request safehouse allocation of player from server
local function OnPlayerInit()
    debugPrint("Initializing player")
    local LoadingScreen = require("ROK/UI/LoadingScreen")
    local Delay = require("ROK/Delay")

    LoadingScreen.Open()
    Delay.Initialize()

    local function CheckMods()
        local unsModsStr = "<CENTRE> <SIZE:large> Unsupported mods found, problems with the economy may arise: <LINE> <LINE> <SIZE:medium>"
        local hasUnsupportedMods = false
		local activeModIDs = getActivatedMods()
		for i=1,activeModIDs:size() do
			local modID = activeModIDs:get(i-1)
            if PZ_EFT_CONFIG.SupportedMods[modID] == nil then
                unsModsStr = unsModsStr .. tostring(modID) .. ", "
                hasUnsupportedMods = true
            end
        end


        if hasUnsupportedMods then
            unsModsStr = unsModsStr:sub(1, -3)      -- Removes last ,
            NotificationPanel.Open(unsModsStr)
        end
    end

    -- Zomboid is a huge piece of shit. We can't use sendClientCommand right after player init since the player isn't actually in game.
    -- Huge workaround, but just delay this function to run 2 seconds after the player has been "created".
    Delay:set(2, function()
        --* Safehouse handling
        -- Request safe house allocation (or just teleport, if it was already done), which in turn will teleport the player to the assigned safehouse
        sendClientCommand(EFT_MODULES.Safehouse, "RequestSafehouseAllocation", {teleport = true})

        --* Shop Items
        debugPrint("Requesting TransmitShopItems to the client now that player is in")
        sendClientCommand(EFT_MODULES.Shop, 'TransmitShopItems', {})

        --* Request bank account and request bank account periodically.
        CratesHandling.ToggleContainersValueUpdate()

        --* Clean map
        ISWorldMap.HandleEFTExits(true)

        --* Request the list of PVP Instances from the server
        ClientData.RequestPvpInstances()

        -- IDEA Add toggle for admin to prevent them from dying\getting punished
        --* Ask server about previous player status
        sendClientCommand(EFT_MODULES.Player, "CheckPlayer", {})

        --* Request extraction time from the server
        sendClientCommand(EFT_MODULES.Match, "SendExtractionTime", {})


        if isAdmin() then
            -- Request current running match, if there is some set the correct UI
            sendClientCommand(EFT_MODULES.Match, 'CheckIsRunningMatch', {})

            -- Notify admins about potentially incompatible mods
            CheckMods()
        end

        -- IDEA maybe migrate a bunch of these functions to events?
        triggerEvent("PZEFT_OnPlayerInitDone")

        LoadingScreen.Close()
    end)

    Events.OnPlayerUpdate.Remove(OnPlayerInit)
end

Events.OnCreatePlayer.Add(function()
    Events.OnPlayerUpdate.Add(OnPlayerInit)
end)



--* Raid handling

-- If player in raid, set that they're not in it anymore
local function OnPlayerExit()
    if ClientState.GetIsInRaid() == false then return end
    debugPrint("Player died, removing him from the raid")
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
    -- UGLY Stupid heavy, figure out a better way to check when a container status changes instead of this crap
    --debugPrint("Update containers value, requesting bank account again")
    local ClientBankManager = require("ROK/Economy/ClientBankManager")
    ClientBankManager.RequestBankAccountFromServer(true)
end

function CratesHandling.ToggleContainersValueUpdate()
    debugPrint("Toggling UpdateCratesValue")

    -- Will get triggered even with Overtime.
    -- Doesn't really cause issues, but keep this in mind


    --debugPrint("Toggling crates handling, isInRaid=" .. tostring(ClientState.GetIsInRaid()))

    if not ClientState.GetIsInRaid() then
        Events.EveryOneMinute.Remove(CratesHandling.UpdateContainersValue)
        Events.EveryOneMinute.Add(CratesHandling.UpdateContainersValue)
    else
        Events.EveryOneMinute.Remove(CratesHandling.UpdateContainersValue)
    end
end

Events.PZEFT_IsInRaidChanged.Add(CratesHandling.ToggleContainersValueUpdate)