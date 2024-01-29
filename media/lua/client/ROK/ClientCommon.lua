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

    local function CheckTeleportStatus()
        debugPrint("Checking is teleport is successful")
        local x = pl:getX()
        local y = pl:getY()
        local z = pl:getZ()
        -- tODO don't be so precise about it, add 1-2 squares to prevent issues
        if x == coords.x and y == coords.y and z == coords.z then
            debugPrint("Successful teleport!")
            Events.OnTick.Remove(CheckTeleportStatus)
            triggerEvent("PZEFT_OnSuccessfulTeleport")
        end
    end

    Events.OnTick.Add(CheckTeleportStatus)

end
------------------------------------------------------------------------
--* COMMANDS FROM SERVER *--
------------------------------------------------------------------------

local MODULE = EFT_MODULES.Common
local CommonCommands = {}

---Teleport the player
---@param args coords
function CommonCommands.Teleport(args)
    ClientCommon.Teleport(args)
end

------------------------------------
local function OnCommonCommand(module, command, args)
    if module == MODULE and CommonCommands[command] then
        --debugPrint("Server Command - " .. MODULE .. "." .. command)
        CommonCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnCommonCommand)



return ClientCommon