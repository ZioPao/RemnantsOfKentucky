---@class ClientCommon
local ClientCommon = {}


-- function ClientCommon.WaitAndRunAfterPlayerInitialization(func, args)
--     local function RunFunction(player)
--         if player == nil or player ~= getPlayer() then return end
--         func(unpack(args))
--         Events.OnPlayerUpdate.Remove(RunFunction)

--     end
--     Events.OnPlayerUpdate.Add(RunFunction)

-- end


function ClientCommon.InstaHeal()
    local pl = getPlayer()
    pl:getBodyDamage():RestoreToFullHealth()
    pl:Say("I feel better now!")
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