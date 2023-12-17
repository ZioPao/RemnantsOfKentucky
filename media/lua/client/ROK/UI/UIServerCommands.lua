local BeforeMatchAdminPanel = require("ROK/UI/BeforeMatch/BeforeMatchAdminPanel")
local DuringMatchAdminPanel = require("ROK/UI/DuringMatch/DuringMatchAdminPanel")
local LoadingScreen = require("ROK/UI/LoadingScreen")
local RecapPanel = require("ROK/UI/AfterMatch/RecapPanel")

local MODULE = EFT_MODULES.UI

------------------------------------------

local InterfaceCommands = {}

function InterfaceCommands.OpenRecapPanel()
    RecapPanel.Open()
end

function InterfaceCommands.OpenLoadingScreen()
    LoadingScreen.Open()
end

function InterfaceCommands.CloseLoadingScreen()
    LoadingScreen.Close()
end

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

------------------------------------------
local function OnInterfaceCommands(module, command, args)
    if module == MODULE and InterfaceCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        InterfaceCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnInterfaceCommands)
