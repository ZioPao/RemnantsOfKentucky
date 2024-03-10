import shutil
from pathlib import Path
import os

x_grid_len = 10
y_grid_len = 10

buffer = 1

inc_x = 4 + buffer
inc_y = 2 + buffer
c_path = Path(__file__).parent

input_dir = c_path / "input"
output_dir = c_path / "output"
temp_dir = c_path / "temp"

if not os.path.exists(output_dir):
    os.mkdir(output_dir)
if not os.path.exists(temp_dir):
    os.mkdir(temp_dir)


def setStartFiles(b_string):
    og_file = b_string.format(x=x, y=y)
    og_file_path =  input_dir / og_file
    copied_file = b_string.format(x=start_x + x, y=start_y + y)
    copied_file_path = temp_dir / copied_file

    shutil.copyfile(og_file_path, copied_file_path)

def copyLoop(base_string, start_x, start_y):
    original_file = base_string.format(x=start_x, y=start_y)
    original_file_path = temp_dir / original_file
    print("Copy Loop: " + base_string)
    print("original_file: " + original_file)
    print("original_file_path: " + str(original_file_path))

    curr_x = 0
    curr_y = 0

    for x in range(0, x_grid_len * inc_x, inc_x):
        curr_x = start_x + x
        for y in range(0, y_grid_len * inc_y, inc_y):
            curr_y = start_y + y
            curr_file = base_string.format(x=curr_x, y=curr_y)
            curr_file_path = output_dir /curr_file

            shutil.copyfile(original_file_path, curr_file_path)


############################
base_lotheader = "{x}_{y}.lotheader"
base_chunkdata = "chunkdata_{x}_{y}.bin"
base_lotpack = "world_{x}_{y}.lotpack"


# Preprocess, set files to the correct name
start_x = 0
end_x = 4
start_y = 0
end_y = 2


for x in range(0, 5):
    for y in range(0, 2):
        setStartFiles(base_lotheader)
        setStartFiles(base_chunkdata)
        setStartFiles(base_lotpack)

        print(x)
        print(y)
    print("_________")



# Actual script running
for x in range(start_x, end_x):
    for y in range(start_y, end_y):
        copyLoop(base_lotheader, start_x=x ,start_y=y)
        copyLoop(base_chunkdata, start_x=x ,start_y=y)
        copyLoop(base_lotpack, start_x=x ,start_y=y)
