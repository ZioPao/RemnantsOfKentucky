require "PZ_EFT_debugtools"

local MODULE = 'PZEFT-Safehouse'

local ServerCommands = {}

--- When client recieves SetSafehouse Server Command
--- Update mod data of player with recieved safehouse data
---@param {x=0, y=0,z=0} Safehouse Instance
ServerCommands.SetSafehouse = function(safehouseInstance)
    local md = PZEFT_UTILS.GetPlayerModData()
    md.safehouse = safehouseInstance
end

ServerCommands.CleanStorage = function(safehouseInstance)
    --TODO Use PZ_EFT_CONFIG.SafehouseInstanceSettings.safehouseStorage instaed
    local x = safehouseInstance.x + PZ_EFT_CONFIG.SafehouseInstanceSettings.storageRelativePosition.x
    local y = safehouseInstance.y + PZ_EFT_CONFIG.SafehouseInstanceSettings.storageRelativePosition.y
    local sq = getCell():getGridSquare(x, y, 0)

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


local OnServerCommand = function(module, command, args)
    if module == MODULE and ServerCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        ServerCommands[command](args)
    end
end


Events.OnServerCommand.Add(OnServerCommand)