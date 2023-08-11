local MODULE = "PZEFT-UI"


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


local OnServerCommand = function(module, command, args)
    if module == MODULE and ServerCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)

