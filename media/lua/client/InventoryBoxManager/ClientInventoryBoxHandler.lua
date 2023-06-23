-- TODO We need to consider if the inventory get reassigned
-- TODO Make the box infinite storage

require "PZ_EFT_debugtools"

 -- This is a placeholder. It should contain where we're gonna place the box relative to the spawnpoint of a safehouse
local RELATIVE_COORDINATES_BOX = {x=1,y=1}


ClientInventoryBoxHandler = ClientInventoryBoxHandler or {}

--- Setup a box inside the specific safehouse instance.
--- The box should be placed always in the same place, relative to the coordinates of the instanced safehouse
---@param safehouse Table ["worldx-worldy-worldz"]={x=worldx, y=worldy, z=worldz}
ClientInventoryBoxHandler.setupBox = function(safehouse)

    -- We have the coordinates for the instance, let's create a box dynamically

end

---Transfer looted items once the player has successfully extracted from the raid
---@param safehouse Table ["worldx-worldy-worldz"]={x=worldx, y=worldy, z=worldz}
ClientInventoryBoxHandler.transferLoot = function(safehouse)

    
end

---Clean a specific instance box from a specific safehouse
---@param safehouse Table ["worldx-worldy-worldz"]={x=worldx, y=worldy, z=worldz}
ClientInventoryBoxHandler.cleanStorage = function(safehouse)

end


