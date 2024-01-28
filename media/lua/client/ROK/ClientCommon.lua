---@class ClientCommon
local ClientCommon = {}

function ClientCommon.InstaHeal()
    local pl = getPlayer()
    pl:getBodyDamage():RestoreToFullHealth()
    pl:Say("I feel better now!")
end

---@param coords coords
function ClientCommon.Teleport(coords)
    local pl = getPlayer()

    pl:setX(coords.x)
    pl:setY(coords.y)
    pl:setZ(coords.z)
    pl:setLx(coords.x)
    pl:setLy(coords.y)
    pl:setLz(coords.z)

end
------------------------------------------------------------------------
--* COMMANDS FROM SERVER *--
------------------------------------------------------------------------

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


    -- TODO Event to notify after teleport is successful... instead of this crap

    -- Send a forced remove zombies, just to be sure.
    local Delay = require("ROK/Delay")
    Delay:set(5, function()
        SendCommandToServer(string.format("/removezombies -remove true"))
    end)
end

------------------------------------
local function OnCommonCommand(module, command, args)
    if (module == MODULE or module == MODULE) and CommonCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        CommonCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnCommonCommand)



return ClientCommon