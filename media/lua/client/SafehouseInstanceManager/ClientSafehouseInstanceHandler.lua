require "PZ_EFT_debugtools"

--- On create player
--- Teleport player to a "neutral"square to remove from any potential safehouse
--- Request safehouse allocation of player from server
---@param player IsoPlayer
local function OnCreatePlayer(_, player)
	if player == getPlayer() then
        --On join, request safehouse allocation data
        debugPrint("On Create Player, RequestSafehouseAllocation")
        --Teleport player to hub 
        -- TODO: maybe change coordinates
        PZEFT_UTILS.TeleportPlayer(player,302,302,0)

        --Request safe house allocation, which in turn will teleport the player to the assigned safehouse
        sendClientCommand("PZEFT-Safehouse", "RequestSafehouseAllocation", {})
    end
end

Events.OnCreatePlayer.Add(OnCreatePlayer)