local BeforeMatchAdminPanel = require("ROK/UI/BeforeMatch/BeforeMatchAdminPanel")
local DuringMatchAdminPanel = require("ROK/UI/DuringMatch/DuringMatchAdminPanel")
local BlackScreen = require("ROK/UI/BeforeMatch/BlackScreen")

local MODULE = EFT_MODULES.UI

------------------------------------------


local ServerCommands = {}

function ServerCommands.OpenBlackScreen()
    BlackScreen.Open()
end

function ServerCommands.CloseBlackScreen()
    BlackScreen.Close()
end

---@param args {startingState : string}
function ServerCommands.SwitchMatchAdminUI(args)
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
function ServerCommands.ReceiveAmountAvailableInstances(args)
    if BeforeMatchAdminPanel.instance == nil then return end
    BeforeMatchAdminPanel.instance:setAvailableInstancesText(tostring(args.amount))
end

---@param args {amount : number}
function ServerCommands.ReceiveAlivePlayersAmount(args)
    if DuringMatchAdminPanel.instance == nil then return end
    DuringMatchAdminPanel.instance:setAlivePlayersText(tostring(args.amount))

end

------------------------------------------
local OnServerCommand = function(module, command, args)
    if module == MODULE and ServerCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)
