local BeforeMatchAdminPanel = require("ROK/UI/BeforeMatch/BeforeMatchAdminPanel")
local DuringMatchAdminPanel = require("ROK/UI/DuringMatch/DuringMatchAdminPanel")
local ClientState = require("ROK/ClientState")

local MODULE = EFT_MODULES.UI

local InterfaceCommands = {}


--* Time Panel commands *--

---@param args {description : string}
function InterfaceCommands.OpenTimePanel(args)
    local TimePanel = require("ROK/UI/TimePanel")
    TimePanel.Close()
    TimePanel.Open(args.description)

    ClientState.SetCurrentTime(100) -- Workaround to prevent the TimePanel from closing
end

---@param args { time : number }
function InterfaceCommands.ReceiveTimeUpdate(args)
    ClientState.SetCurrentTime(args.time)
    -- Locally, 1 player, about 4-5 ms of delay.
end


--* Recap Panel commands *--
function InterfaceCommands.OpenRecapPanel()
    local RecapPanel = require("ROK/UI/AfterMatch/RecapPanel")
    RecapPanel.Open()
end


--* Loading Screen commands *--
function InterfaceCommands.OpenLoadingScreen()
    local LoadingScreen = require("ROK/UI/LoadingScreen")
    LoadingScreen.Open()
end

function InterfaceCommands.CloseLoadingScreen()
    local LoadingScreen = require("ROK/UI/LoadingScreen")
    LoadingScreen.Close()
end


--* Admin Panel Commands *--

---@param args {startingState : string}
function InterfaceCommands.SwitchMatchAdminUI(args)
    -- Check if admin UI is already open. If it is, closes it and opens the during match one
    local startingState = args.startingState

    if startingState == 'BEFORE' then
        if BeforeMatchAdminPanel.OnClosePanel() then
            DuringMatchAdminPanel.OnOpenPanel()
        end
    elseif startingState == 'DURING' then
        if DuringMatchAdminPanel.OnClosePanel() then
            BeforeMatchAdminPanel.OnOpenPanel()
        end
    end
end

--- Sets the amount of available instances to the client state
---@param args {amount : integer}
function InterfaceCommands.ReceiveAmountAvailableInstances(args)
    if BeforeMatchAdminPanel.instance == nil then return end
    BeforeMatchAdminPanel.instance:setAvailableInstancesText(tostring(args.amount))
end

---@param args {amount : number}
function InterfaceCommands.ReceiveAlivePlayersAmount(args)
    if DuringMatchAdminPanel.instance == nil then return end
    DuringMatchAdminPanel.instance:setAlivePlayersText(tostring(args.amount))

end

--- During Match Admin Panel -> Options Panel
---@param args { spawnZombieMultiplier : number }
function InterfaceCommands.ReceiveCurrentZombieSpawnMultiplier(args)
    local OptionsPanel = require("ROK/UI/DuringMatch/OptionsPanel")
    if OptionsPanel.instance == nil then return end
    local optRef = OptionsPanel.GetOptionsReference()
    local panelName = optRef.ZombieSpawnMultiplier.panelName

    ---@type ISTextEntryBox
    local entry = OptionsPanel.instance[panelName].entry
    entry:setText(tostring(args.spawnZombieMultiplier))
    entry:setEditable(true)
    entry.syncedWithServer = true
end


------------------------------------------
local function OnInterfaceCommands(module, command, args)
    if module == MODULE and InterfaceCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        InterfaceCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnInterfaceCommands)
