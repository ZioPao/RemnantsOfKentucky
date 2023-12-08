local ClientCommon = {}


---@param playerIndex number
local function HandleAutoHeal(playerIndex)


    local function WaitForGodMode()
        local pl = getPlayer()
        if pl:isGodMod() == false then return end
        pl:setGodMod(true)
        pl:Say("I feel better now")
        Events.OnTick.Remove(WaitForGodMode)
    end

    local pl = getPlayer()
    local plInv = pl:getInventory()
    local item = plInv:FindAndReturn("AutoHeal")
    if item == nil then
        pl:Say("I need to have the AutoHeal in my inventory")
    else

        pl:setGodMod(true)
        Events.OnTick.Add(WaitForGodMode)
        plInv:Remove(item)
    end

end


local function OnFillInventoryObjectContextMenu(playerIndex, context, items)
    if items[1] then
        local item = items[1]
        if item.name == 'Auto Heal' then
            context:addOption("Heal yourself", playerIndex, HandleAutoHeal)
        end
    end
end


Events.OnFillInventoryObjectContextMenu.Add(OnFillInventoryObjectContextMenu)






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