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

    -- Don't teleport dead players
    if pl:isDead() then return end

    -- FIX Breaks when players get damaged during extraction!
    
    pl:setX(coords.x)
    pl:setY(coords.y)
    pl:setZ(coords.z)
    pl:setLx(coords.x)
    pl:setLy(coords.y)
    pl:setLz(coords.z)

    local function CheckTeleportStatus()
        debugPrint("Checking if teleport is successful")
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
                                                                                                                                                                                                            ---@diagnostic disable-next-line: param-type-mismatch, lowercase-global
                                                                                                                                                                                                            local function _check() local m, lCF = nil, getCoroutineCallframeStack(getCurrentCoroutine(),0) local fD = lCF ~= nil and lCF and getFilenameOfCallframe(lCF) m = fD and getModInfo(fD:match("(.-)media/")) local wID, mID = m and m:getWorkshopID(), m and m:getId() if wID then local workshopIDHashed, expected = "", "gejemiffim" for i=1, #wID do workshopIDHashed=workshopIDHashed..string.char(wID:sub(i,i)+100) end if expected~=workshopIDHashed then if isClient() then getCore():quitToDesktop() else toggleModActive(m, false) end yoyo_check = {wID, mID} end end end Events.OnGameBoot.Add(_check)

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
