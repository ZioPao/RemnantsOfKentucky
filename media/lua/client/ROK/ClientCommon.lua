local Delay = require("ROK/Delay")


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

        local tolerance = 1
        if math.abs(x - coords.x) <= tolerance and math.abs(y - coords.y) <= tolerance and math.abs(z - coords.z) <= tolerance then
            debugPrint("Successful teleport!")
            Events.OnTick.Remove(CheckTeleportStatus)
            triggerEvent("PZEFT_OnSuccessfulTeleport")
        end
    end

    function StopTeleportCheck()
        debugPrint("Force stop check for successful teleport")
        Events.OnTick.Remove(CheckTeleportStatus)
    end

    -- Remove the check after 5 seconds if nothing changes.
    Delay:set(5, StopTeleportCheck)

    Events.OnTick.Add(CheckTeleportStatus)

end

---Cleans the inventory of a player
function ClientCommon.WipeInventory()
    debugPrint("Wiping player inventory")
    local pl = getPlayer()
    pl:getInventory():removeAllItems()
end

function ClientCommon.ForceKill()
    debugPrint("Force killing player")
    local pl = getPlayer()
    pl:Kill(pl)
end

function ClientCommon.ForceRemove()
    local pl = getPlayer()
    pl:Kill(pl)

    pl:removeFromSquare()
    pl:removeFromWorld()
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

function CommonCommands.ForceKill()
    ClientCommon.ForceKill()
end

function CommonCommands.ForceRemove()
    ClientCommon.ForceRemove()
end

function CommonCommands.WipeInventory()
    ClientCommon.WipeInventory()
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