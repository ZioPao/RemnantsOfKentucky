require "PZ_EFT_debugtools"
require "PZEFT_Utils"
require "PZ_EFT_config"

local MODULE = 'PZEFT-Shop'

local ServerCommands = {}

ServerCommands.BuyItem = function(args)
    print("BuyItem")

    if args and args.item and args.quantity then
        local cratesTable = ClientSafehouseInstanceHandler.GetCrates()
        -- Find the first crate which has available space
        -- TODO Do it
        
        local crate = cratesTable[1]
        crate:AddItems(args.item.fullType, args.quantity)
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
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)
