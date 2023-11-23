require "PZEFT_debugtools"
local ClientState = require("ROK/ClientState")
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
------------------------------------
local OnCommonCommand = function(module, command, args)
    if (module == MODULE or module == MODULE) and CommonCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        CommonCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnCommonCommand)
