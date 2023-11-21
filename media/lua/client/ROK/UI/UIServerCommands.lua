local BeforeMatchAdminPanel = require("ROK/UI/BeforeMatch/BeforeMatchAdminPanel")
local DuringMatchAdminPanel = require("ROK/UI/DuringMatch/DuringMatchAdminPanel")

local MODULE = "PZEFT-UI"
local TIME_PANEL_DESCRIPTIONS = {
    getText("IGUI_TimePanel_MatchStarting"),        -- 1
    getText("IGUI_TimePanel_MatchEnded")            -- 2
}

------------------------------------------


local ServerCommands = {}

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

---@param args {index : integer}
function ServerCommands.SetTimePanelDescription(args)
    local index = args.index
    TimePanel.instance:setDescription(TIME_PANEL_DESCRIPTIONS[index])
end

------------------------------------------
local OnServerCommand = function(module, command, args)
    if module == MODULE and ServerCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)
