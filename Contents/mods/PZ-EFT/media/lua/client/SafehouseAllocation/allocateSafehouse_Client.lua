local function OnCreatePlayer(playerIndex, player)
	if player == getPlayer() then
        --On join, request safehouse allocation data
        print("On Create Player, RequestSafehouseAllocation");
        --Teleport player to hub 
        -- TODO: maybe change coordinates
        PZEFT_UTILS.TeleportPlayer(player,302,302,0);

        --Request safe house allocation, which in turn will teleport the player to the assigned safehouse
        sendClientCommand("PZEFT", "RequestSafehouseAllocation", {})
    end
end

Events.OnCreatePlayer.Add(OnCreatePlayer)