import shutil
import os

cwd = os.getcwd()

input_dir = os.path.join(cwd, "python_scripts", "input")
output_dir = os.path.join(cwd, "output")

if not os.path.exists(output_dir):
    os.mkdir(output_dir)

base_code = 'ShopItemsManager.AddItem("{}", {{["{}"] = true}}, {}, 1, 0.5)'

def read_line(file_path):
    with open(file_path, 'r') as file:
        for line in file:
            pairs = line.strip().split(", ")
            
            item_data = dict(pair.split(': ') for pair in pairs)

            full_type = item_data.get('fullType')
            if full_type != "Base.GranolaBar" and full_type != "Base.WaterBottleFull" and full_type != "Base.Cereal" and full_type != "Base.Butter" and full_type != "Base.Baseballbat" and full_type != "Base.Crowbar" and full_type != "Base.ShotgunSawnoff" and full_type != "Base.ShotgunShellsBox" and full_type != "Base.ShotgunShellsBox" and full_type != "Base.Pistol" and full_type != "Base.9mmClip" and full_type != "Base.Bullets9mmBox" and full_type != "Base.Bandage":
                base_price = str(item_data.get('basePrice'))
                tag = item_data.get('tag')

                test = base_code.format(full_type, tag, base_price)
                print(test)
            #formatted_code = base_code.format(full_type, tag, base_price)
            #print(formatted_code)
            #     ShopItemsManager.AddItem("Base.GranolaBar", {["ESSENTIALS"] = true}, 20, 1, 0.5)



file_path = os.path.join(input_dir, "itemsDump.txt")

read_line(file_path=file_path)