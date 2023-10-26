local function EveryOneMinute()
	if isAdmin() then
        for _,v in ipairs(PZ_EFT_CONFIG.SafehouseCells)do
            zpopClearZombies(v.x,v.y)
        end
    end
end

Events.EveryOneMinute.Add(EveryOneMinute)