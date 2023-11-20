local function EveryOneMinute()
    -- TODO Bit inefficient, we should select a single admin instead of running this on every one. Also, not sure if works at all
	if isAdmin() then
        for _,v in ipairs(PZ_EFT_CONFIG.SafehouseCells)do
            zpopClearZombies(v.x,v.y)
        end
    end
end

Events.EveryOneMinute.Add(EveryOneMinute)