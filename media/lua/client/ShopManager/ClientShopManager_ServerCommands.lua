require "PZ_EFT_debugtools"
require "PZEFT_Utils"

local MODULE = 'PZEFT-Shop'

local ServerCommands = {}

--- Add items to inventory
ServerCommands.BuyItems = function(args)
    local item = args.item
    local quantity = args.quantity

    local player = getPlayer()
    local inventory = player:getInventory()
    inventory:AddItems(item.fullType, quantity)
end

ServerCommands.SellItems = function(args)
    local item = args.item
    local quantity = args.quantity

    local player = getPlayer()
    local inventory = player:getInventory()
    --Get all items in inventory
    --Remove items that fit the criteria for x amount of quantity
    --TODO: REMOVE ITEM FOR QUANTITY
end

ServerCommands.BuyFailed = function(args)
    print("Sell Failed!")
    PZEFT_UTILS.PrintTable(args, " - ")
end

ServerCommands.SellFailed = function(args)
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
