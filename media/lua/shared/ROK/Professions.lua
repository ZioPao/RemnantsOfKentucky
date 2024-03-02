Events.OnGameBoot.Remove(BaseGameCharacterDetails.DoProfessions)

local function SetEFTProfessionDescription(prof)
	local desc = getTextOrNull("UI_EFT_Profession_" .. prof:getType() .. "_Desc") or ""
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
        if info and desc then
            desc = desc .. info.levelStr .. " " .. info.perkName
        end
	end
	local traits = prof:getFreeTraits()
	for j=1,traits:size() do
		if desc ~= "" then desc = desc .. "\n" end
		local traitName = traits:get(j-1)
		local trait = TraitFactory.getTrait(traitName)
		desc = desc .. trait:getLabel()
	end
	prof:setDescription(desc)

    --debugPrint(desc)

end

local function CreateEFTProfessions()

    -- Icon by Voysla on Flaticon
    local sharpShooter = ProfessionFactory.addProfession("SharpShooter", getText("UI_EFT_Profession_SharpShooter"), "Professions/sharpShooter", -14)
    sharpShooter:addFreeTrait("Desensitized")
    sharpShooter:addXPBoost(Perks.Aiming, 7)
    sharpShooter:addXPBoost(Perks.Reloading, 7)
    sharpShooter:addXPBoost(Perks.Sprinting, 2)
    sharpShooter:addXPBoost(Perks.SmallBlade, 2)
    sharpShooter:addXPBoost(Perks.Blunt, 2)
    sharpShooter:addXPBoost(Perks.Maintenance, 4)

    SetEFTProfessionDescription(sharpShooter)

    -- LAFS on FlatIcon
    local brawler = ProfessionFactory.addProfession("Brawler", getText("UI_EFT_Profession_Brawler"), "Professions/brawler", -8)
    brawler:addFreeTrait("Desensitized")
    brawler:addXPBoost(Perks.Strength, 1)
    brawler:addXPBoost(Perks.Fitness, 1)
    brawler:addXPBoost(Perks.Aiming, 3)
    brawler:addXPBoost(Perks.Reloading, 2)
    brawler:addXPBoost(Perks.SmallBlade, 5)
    brawler:addXPBoost(Perks.SmallBlunt, 3)
    brawler:addXPBoost(Perks.Spear, 3)
    brawler:addXPBoost(Perks.Axe, 3)
    brawler:addXPBoost(Perks.Maintenance, 7)

    SetEFTProfessionDescription(brawler)

    -- SumberRejeki on FlatIcon
    local medic = ProfessionFactory.addProfession("Medic", getText("UI_EFT_Profession_Medic"), "Professions/medic", -4)
    medic:addXPBoost(Perks.Fitness, 2)
    medic:addXPBoost(Perks.Aiming, 2)
    medic:addXPBoost(Perks.Reloading, 4)
    medic:addXPBoost(Perks.SmallBlade, 7)
    medic:addXPBoost(Perks.LongBlade, 2)
    medic:addXPBoost(Perks.Doctor, 7)
    medic:addXPBoost(Perks.Lightfoot, 3)
    medic:addXPBoost(Perks.Nimble, 5)
    SetEFTProfessionDescription(medic)

    -- Frepik on FlatIcon
    local scavenger = ProfessionFactory.addProfession("Scavenger", getText("UI_EFT_Profession_Scavenger"), "Professions/scavenger", -6)
    scavenger:addXPBoost(Perks.Strength, 2)
    scavenger:addXPBoost(Perks.Fitness, 1)
    scavenger:addXPBoost(Perks.Aiming, 3)
    scavenger:addXPBoost(Perks.Reloading, 3)
    scavenger:addXPBoost(Perks.SmallBlunt, 4)
    scavenger:addXPBoost(Perks.Blunt, 2)
    scavenger:addXPBoost(Perks.Nimble, 2)
    scavenger:addXPBoost(Perks.Sprinting, 4)
    SetEFTProfessionDescription(scavenger)
end


local og_BaseGameCharacterDetailsDoProfessions = BaseGameCharacterDetails.DoProfessions
function BaseGameCharacterDetails.DoProfessions()
    og_BaseGameCharacterDetailsDoProfessions()
    CreateEFTProfessions()
end

Events.OnGameBoot.Add(BaseGameCharacterDetails.DoProfessions)
