ServerData_client_debug = ServerData_client_debug or {}

function ServerData_client_debug.loadNewInstances()
    sendClientCommand("SERVER_DEBUG", "loadNewInstances", {})
end

function ServerData_client_debug.getNextInstance()
    sendClientCommand("SERVER_DEBUG", "getNextInstance", {})
end

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