local BeforeMatchAdminPanel = require("EFTUI/BeforeMatch/BeforeMatchAdminPanel")
local DuringMatchAdminPanel = require("EFTUI/DuringMatch/DuringMatchAdminPanel")


local MODULE = "PZEFT-UI"
local TIME_PANEL_DESCRIPTIONS = {
    "The match is starting",        -- 1
    "The match has ended"           -- 2
}
local ServerCommands = {}


ServerCommands.SwitchMatchAdminUI = function(args)

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

ServerCommands.SetTimePanelDescription = function (args)
    local index = args.index
    -- TODO Fetch from a locally saved array of strings
    TimePanel.instance:setDescription(TIME_PANEL_DESCRIPTIONS[index])
end

local OnServerCommand = function(module, command, args)
    if module == MODULE and ServerCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)

