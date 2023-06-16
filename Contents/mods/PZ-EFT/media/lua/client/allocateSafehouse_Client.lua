--TODO: DEBUGGING
local function OnPlayerAttackFinished(character, handWeapon)
    local p = getPlayer()

    local psq = p:getSquare()

    local x = psq:getX()
    local y = psq:getY()

    local cx = math.floor(x / 300)
    local cy = math.floor(y / 300)

    local rx = x - (cx * 300)
    local ry = y - (cy * 300)

    local s = "CellX: " .. cx .. " CellY: " .. cy .. " RelX: " .. rx .. " RelY: " .. ry .. " WorldX: " .. x .. " WorldY: " .. y

    Clipboard.setClipboard(s)
    print(s)
end

Events.OnPlayerAttackFinished.Add(OnPlayerAttackFinished)


local function OnCreatePlayer(playerIndex, player)
	if player == getPlayer() then
        --On join, request safehouse allocation data
        print("On Create Player, RequestSafehouseAllocation");
        --Teleport player to hub
        PZEFT_UTILS.TeleportPlayer(player,302,302,0);

        --Request safe house allocation, which in turn will teleport the player to the assigned safehouse
        sendClientCommand("PZEFT", "RequestSafehouseAllocation", {})
    end
end

Events.OnCreatePlayer.Add(OnCreatePlayer)