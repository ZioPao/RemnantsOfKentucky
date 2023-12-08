require "ROK/ShopItems/ShopItems"


PZ_EFT_ShopItems_Config.AddItem("Base.GranolaBar", {["ESSENTIALS"] = true}, 20, 1, 0.5)
PZ_EFT_ShopItems_Config.AddItem("Base.WaterBottleFull", {["ESSENTIALS"] = true}, 50, 1, 0.5)
PZ_EFT_ShopItems_Config.AddItem("Base.Cereal", {["ESSENTIALS"] = true}, 20, 1, 0.5)
PZ_EFT_ShopItems_Config.AddItem("Base.Butter", {["ESSENTIALS"] = true}, 500, 1, 0.5)
PZ_EFT_ShopItems_Config.AddItem("Base.BaseballBat", {["ESSENTIALS"] = true}, 200, 1, 0.5)
PZ_EFT_ShopItems_Config.AddItem("Base.Crowbar", {["ESSENTIALS"] = true}, 1000, 1, 0.5)
PZ_EFT_ShopItems_Config.AddItem("Base.ShotgunSawnoff", {["ESSENTIALS"] = true}, 1500, 1, 0.5)
PZ_EFT_ShopItems_Config.AddItem("Base.ShotgunShellsBox", {["ESSENTIALS"] = true}, 250, 1, 0.5)
PZ_EFT_ShopItems_Config.AddItem("Base.Pistol", {["ESSENTIALS"] = true}, 750, 1, 0.5)
PZ_EFT_ShopItems_Config.AddItem("Base.9mmClip", {["ESSENTIALS"] = true}, 250, 1, 0.5)
PZ_EFT_ShopItems_Config.AddItem("Base.Bullets9mmBox", {["ESSENTIALS"] = true}, 250, 1, 0.5)
PZ_EFT_ShopItems_Config.AddItem("Base.Bandage", {["ESSENTIALS"] = true}, 100, 1, 0.5)
-- TODO Add Auto Heal object

-------------------------

if isServer() then
    PZ_EFT_ShopItems_Config.GenerateDailyItems()
end

--PZ_EFT_ShopItems_Config.AddItem("Base.Acorn", {["HIGHVALUE"] = true}, 100, 0.5, 0.7)
-- PZ_EFT_ShopItems_Config.AddItem("Base.GuitarAcoustic", {["HIGHVALUE"] = true}, 100, 0.5, 0.7)
-- PZ_EFT_ShopItems_Config.AddItem("Base.Bullets9mm", {["HIGHVALUE"] = true}, 100, 0.5, 0.7)
-- PZ_EFT_ShopItems_Config.AddItem("Base.Allsorts", {["HIGHVALUE"] = true}, 100, 0.5, 0.7)
-- PZ_EFT_ShopItems_Config.AddItem("Base.Bandaid", {["LOWVALUE"] = true}, 100, 0.5, 0.7)
-- PZ_EFT_ShopItems_Config.AddItem("Base.Amplifier", {["LOWVALUE"] = true}, 100, 0.5, 0.7)
-- PZ_EFT_ShopItems_Config.AddItem("Base.Antibiotics", {["LOWVALUE"] = true}, 100, 0.5, 0.7)
-- PZ_EFT_ShopItems_Config.AddItem("Base.Avocado", {["LOWVALUE"] = true}, 100, 0.5, 0.7)