require "PZ_EFT_debugtools"
require "PZEFT_Utils"
require "PZ_EFT_config"

local MODULE = 'PZEFT-Shop'

local ServerCommands = {}

ServerCommands.BuyItem = function(args)
    if args and args.item and args.quantity then
    local safehouse = ClientSafehouseInstanceHandler.getSafehouse()
    local storageRelativePos = PZ_EFT_CONFIG.SafehouseInstanceSettings.storageRelativePosition;
    if safehouse then
        local container = {x = safehouse.x + storageRelativePos.x, y = safehouse.y + storageRelativePos.y, z = safehouse.z + storageRelativePos.z}
        local square = getCell():getGridSquare(container.x, container.y, container.z)
        --TODO: Get container on square and get its ItemContainer
        local inventory = nil
        inventory:AddItems(args.item, args.quantity)
    else
        print("ERROR: ServerCommands.BuyItem - Invalid safehouse")
    end
else
    print("ERROR: ServerCommands.BuyItem - Invalid buyData (args)")
end
end

ServerCommands.SellItems = function(args)
    local player = getPlayer()
    local inventory = player:getInventory()

    for _, itemData in ipairs(args) do
        if itemData and itemData.item and itemData.quantity then
            for i = 1, itemData.quantity do
                inventory:Remove(itemData.item)
            end
        else
            print("ERROR: ServerCommands.SellItems - Invalid sellData")
            return;
        end
    end
end

ServerCommands.BuyFailed = function(args)
    --TODO: Maybe handle this on the UI somehow?
    print("Sell Failed!")
    PZEFT_UTILS.PrintTable(args, " - ")
end

ServerCommands.SellFailed = function(args)
    --TODO: Maybe handle this on the UI somehow?
    print("Sell Failed!")
    PZEFT_UTILS.PrintTable(args, " - ")
end

local OnServerCommand = function(module, command, args)
    if module == MODULE and ServerCommands[command] then
        debugPrint("Server Command - " .. MODULE .. "." .. command)
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)
