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

    Clipboard.setClipboard(s);
    print(s)

    SafehouseInstanceManager.loadSafehouseInstances(1,1);
    print("Total: " .. SafehouseInstanceManager.getTotalSafehouseInstanceCount())
    print("Free: " .. SafehouseInstanceManager.getFreeSafehouseCount())
    print("Assigned: " .. SafehouseInstanceManager.getAssignedSafehouseCount())
end

Events.OnPlayerAttackFinished.Add(OnPlayerAttackFinished)