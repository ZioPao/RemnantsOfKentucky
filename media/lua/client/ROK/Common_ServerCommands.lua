require "PZEFT_debugtools"
-----------------------------

local MODULE = EFT_MODULES.Common
local CommonCommands = {}

---Teleport the player
---@param args coords
function CommonCommands.Teleport(args)
    local player = getPlayer()
    player:setX(args.x)
    player:setY(args.y)
    player:setZ(args.z)
    player:setLx(args.x)
    player:setLy(args.y)
    player:setLz(args.z)
end


function CommonCommands.ReceiveStarterKit()
    debugPrint("ReceiveStarterKit")
    local ClientCommon = require("ROK/ClientCommon")
    ClientCommon.GiveStarterKit(getPlayer(), true)
end

------------------------------------
local OnCommonCommand = function(module, command, args)
    if (module == MODULE or module == MODULE) and CommonCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        CommonCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnCommonCommand)
