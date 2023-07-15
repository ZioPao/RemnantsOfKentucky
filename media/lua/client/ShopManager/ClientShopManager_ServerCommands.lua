require "PZ_EFT_debugtools"
require "PZEFT_Utils"

local MODULE = 'PZEFT-Shop'

local ServerCommands = {}

--- Add items to inventory
ServerCommands.BuyItems = function(args)
    --TODO: When buying, items are delivered in a cardboard box next to the safehouse's front door
    --TODO: Handle multiple items
end

ServerCommands.SellItems = function(args)
    local player = getPlayer()
    local inventory = player:getInventory()

    --TODO: Handle multiple items
    for _, itemData in ipairs(args) do 
        --Get all items in inventory
        --Remove items that fit the criteria for x amount of quantity
        --TODO: REMOVE ITEM FOR QUANTITY 
    end
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
