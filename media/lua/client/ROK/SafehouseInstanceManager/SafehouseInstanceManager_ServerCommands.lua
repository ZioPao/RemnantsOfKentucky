require "PZ_EFT_debugtools"
local MODULE = 'PZEFT-Safehouse'

-------------------------

local ServerCommands = {}

--- When client recieves SetSafehouse Server Command
--- Update mod data of player with recieved safehouse data
---@param safehouseCoords coords {x=0, y=0,z=0} Safehouse Instance
ServerCommands.SetSafehouse = function(safehouseCoords)
    local md = PZEFT_UTILS.GetPlayerModData()
    md.safehouse = safehouseCoords
end

ServerCommands.CleanStorage = function()
    -- TODO Test this
    for _, group in pairs(PZ_EFT_CONFIG.SafehouseInstanceSettings.safehouseStorage) do
        local sq = getCell():getGridSquare(group.x, group.y, 0)
        local objects = sq:getObjects()
        local inventoryContainer
        for i=1, objects:size() do
            if instanceof(objects:get(i), "InventoryItem") then
                inventoryContainer = objects:get(i):getContainer()
                if inventoryContainer then
                    inventoryContainer:clear()
                else
                    error("Crate found, but no InventoryContainer")
    
                end
            end
        end
    end

end

------------------------

local OnServerCommand = function(module, command, args)
    if module == MODULE and ServerCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        ServerCommands[command](args)
    end
end


Events.OnServerCommand.Add(OnServerCommand)