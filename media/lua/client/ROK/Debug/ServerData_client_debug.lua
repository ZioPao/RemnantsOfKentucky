ServerData_client_debug = ServerData_client_debug or {}

-- PVP Instance Handling --

function ServerData_client_debug.loadNewInstances()
    sendClientCommand("SERVER_DEBUG", "loadNewInstances", {})
end

-- Print Data To Server Console --

function ServerData_client_debug.print_pvp_instances()
    sendClientCommand("SERVER_DEBUG", "print_pvp_instances", {})
end

function ServerData_client_debug.print_pvp_usedinstances()
    sendClientCommand("SERVER_DEBUG", "print_pvp_usedinstances", {})
end

function ServerData_client_debug.print_pvp_currentinstance()
    sendClientCommand("SERVER_DEBUG", "print_pvp_currentinstance", {})
end

function ServerData_client_debug.print_safehouses()
    sendClientCommand("SERVER_DEBUG", "print_safehouses", {})
end

function ServerData_client_debug.print_assignedsafehouses()
    sendClientCommand("SERVER_DEBUG", "print_assignedsafehouses", {})
end

function ServerData_client_debug.print_bankaccounts()
    sendClientCommand("SERVER_DEBUG", "print_bankaccounts", {})
end

function ServerData_client_debug.print_shopitems()
    sendClientCommand("SERVER_DEBUG", "print_shopitems", {})
end

function ServerData_client_debug.loadShopPrices()
    -- !!! THIS IS TO LET THE SERVER GENERATE THE SHOP ITEMS AND TRANSMIT THEM !!!
    sendClientCommand("SERVER_DEBUG", "loadShopPrices", {})
end

-- function ServerData_client_debug.transmit_shop_prices()
--     sendClientCommand("SERVER_DEBUG")
-- end

-- Match Handling --

function ServerData_client_debug.getNextInstance()
    sendClientCommand("SERVER_DEBUG", "getNextInstance", {})
end

function ServerData_client_debug.TeleportPlayersToInstance()
    sendClientCommand("SERVER_DEBUG", "TeleportPlayersToInstance", {})
end

function ServerData_client_debug.sendPlayersToSafehouse()
    sendClientCommand("SERVER_DEBUG", "sendPlayersToSafehouse", {})
end


-- Bank handling --

function ServerData_client_debug.setBankAccount(name, balance)
    sendClientCommand("SERVER_DEBUG", "setBankAccount", {name = name, balance = balance} )
end
