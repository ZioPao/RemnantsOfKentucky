require "ROK/ShopItems/ShopItems"

-- TODO In theory we need to account for every item, basically. Or do we just assign a random value to the sold one?
--[[
how should the sold items cost it be calculated? I guess you 
would want to have a multiplier to decrease their cost by some
amount compared to the normal
--]]

PZ_EFT_ShopItems_Config.AddItem("Base.Apple", {["ESSENTIALS"] = true}, 20, 1, 0.5)
PZ_EFT_ShopItems_Config.AddItem("Base.Bandage", {["ESSENTIALS"] = true}, 20, 1, 0.5)
PZ_EFT_ShopItems_Config.AddItem("Base.WaterBottleFull", {["ESSENTIALS"] = true}, 20, 1, 0.5)


-------------------------


PZ_EFT_ShopItems_Config.AddItem("Base.Shovel", {["JUNK"] = true}, 100, 0.5, 0.7)
PZ_EFT_ShopItems_Config.AddItem("Base.Acorn", {["HIGHVALUE"] = true}, 100, 0.5, 0.7)
PZ_EFT_ShopItems_Config.AddItem("Base.GuitarAcoustic", {["HIGHVALUE"] = true}, 100, 0.5, 0.7)
PZ_EFT_ShopItems_Config.AddItem("Base.Bullets9mm", {["HIGHVALUE"] = true}, 100, 0.5, 0.7)
PZ_EFT_ShopItems_Config.AddItem("Base.Allsorts", {["HIGHVALUE"] = true}, 100, 0.5, 0.7)
PZ_EFT_ShopItems_Config.AddItem("Base.Bandaid", {["LOWVALUE"] = true}, 100, 0.5, 0.7)
PZ_EFT_ShopItems_Config.AddItem("Base.Amplifier", {["LOWVALUE"] = true}, 100, 0.5, 0.7)
PZ_EFT_ShopItems_Config.AddItem("Base.Antibiotics", {["LOWVALUE"] = true}, 100, 0.5, 0.7)
PZ_EFT_ShopItems_Config.AddItem("Base.Avocado", {["LOWVALUE"] = true}, 100, 0.5, 0.7)