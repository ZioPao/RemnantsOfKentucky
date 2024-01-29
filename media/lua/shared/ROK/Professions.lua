

function SetEFTProfessionDescription(prof)
	local desc = getTextOrNull("UI_EFT_Profession_" .. prof:getType() .. "_Desc")
	local boost = transformIntoKahluaTable(prof:getXPBoostMap())
	local infoList = {}
	for perk,level in pairs(boost) do
		local perkName = PerkFactory.getPerkName(perk)
		-- "+1 Cooking" etc
		local levelStr = tostring(level:intValue())
		if level:intValue() > 0 then levelStr = "+" .. levelStr end
		table.insert(infoList, { perkName = perkName, levelStr = levelStr })
	end
	table.sort(infoList, function(a,b) return not string.sort(a.perkName, b.perkName) end)
	for _,info in ipairs(infoList) do
		if desc and desc ~= "" then desc = desc .. "\n" end
		desc = desc .. info.levelStr .. " " .. info.perkName
	end
	local traits = prof:getFreeTraits()
	for j=1,traits:size() do
		if desc ~= "" then desc = desc .. "\n" end
		local traitName = traits:get(j-1)
		local trait = TraitFactory.getTrait(traitName)
		desc = desc .. trait:getLabel()
	end
	prof:setDescription(desc)

    debugPrint(desc)

end


-- TODO When player dies, these do not appear anymore

Events.OnGameBoot.Add(function()
    local sharpShooter = ProfessionFactory.addProfession("SharpShooter", getText("UI_EFT_Profession_SharpShooter"), "profession_veteran2", -4)
    sharpShooter:addFreeTrait("Desensitized")
    sharpShooter:addXPBoost(Perks.Aiming, 2)
    sharpShooter:addXPBoost(Perks.Reloading, 2)
    sharpShooter:addXPBoost(Perks.SmallBlade, -3)
    sharpShooter:addXPBoost(Perks.Blunt, -3)
    sharpShooter:addXPBoost(Perks.Maintenance, -1)
    SetEFTProfessionDescription(sharpShooter)

    local brawler = ProfessionFactory.addProfession("Brawler", getText("UI_EFT_Profession_Brawler"), "profession_chef2", -4)
    brawler:addFreeTrait("Desensitized")
    brawler:addXPBoost(Perks.Strength, 1)
    brawler:addXPBoost(Perks.Fitness, 1)
    brawler:addXPBoost(Perks.Aiming, -2)
    brawler:addXPBoost(Perks.Reloading, -3)
    brawler:addXPBoost(Perks.SmallBlade, -2)
    brawler:addXPBoost(Perks.SmallBlunt, -2)
    brawler:addXPBoost(Perks.Spear, -2)
    brawler:addXPBoost(Perks.Axe, -2)
    brawler:addXPBoost(Perks.Maintenance, 2)
    SetEFTProfessionDescription(brawler)

    local medic = ProfessionFactory.addProfession("Medic", getText("UI_EFT_Profession_Medic"), "profession_doctor2", -4)
    medic:addXPBoost(Perks.Fitness, 2)
    medic:addXPBoost(Perks.Aiming, -3)
    medic:addXPBoost(Perks.Reloading, -1)
    medic:addXPBoost(Perks.SmallBlade, 2)
    medic:addXPBoost(Perks.LongBlade, -3)
    medic:addXPBoost(Perks.Doctor, 2)
    medic:addXPBoost(Perks.Lightfoot, -2)
    SetEFTProfessionDescription(medic)

    local scavenger = ProfessionFactory.addProfession("Scavenger", getText("UI_EFT_Profession_Scavenger"), "profession_chef2", -4)
    scavenger:addXPBoost(Perks.Strength, 2)
    scavenger:addXPBoost(Perks.Fitness, 1)
    scavenger:addXPBoost(Perks.Aiming, -2)
    scavenger:addXPBoost(Perks.Reloading, -2)
    scavenger:addXPBoost(Perks.SmallBlunt, -1)
    scavenger:addXPBoost(Perks.Blunt, -3)
    scavenger:addXPBoost(Perks.Nimble, -3)
    scavenger:addXPBoost(Perks.Sprinting, -1)
    SetEFTProfessionDescription(scavenger)


end)