import shutil
import os

x_grid_len = 10
y_grid_len = 10

buffer = 1

inc_x = 4 + buffer
inc_y = 2 + buffer

cwd = os.getcwd()

input_dir = os.path.join(cwd, "dev", "python_scripts", "map_data")
output_dir = os.path.join(cwd, "dev", "python_scripts", "map_output")

if not os.path.exists(output_dir):
    os.mkdir(output_dir)


def copyLoop(base_string):
    original_file = base_string.format(x=start_x, y=start_y)
    original_file_path = os.path.join(input_dir, original_file)
    print("Copy Loop: " + base_string)
    print("original_file: " + original_file)
    print("original_file_path: " + original_file_path)

    curr_x = 0
    curr_y = 0

    for x in range(0, x_grid_len * inc_x, inc_x):
        curr_x = start_x + x
        for y in range(0, y_grid_len * inc_y, inc_y):
            curr_y = start_y + y
            curr_file = base_string.format(x=curr_x, y=curr_y)
            curr_file_path = os.path.join(output_dir, curr_file)

            shutil.copyfile(original_file_path, curr_file_path)


############################
base_lotheader = "{x}_{y}.lotheader"
base_chunkdata = "chunkdata_{x}_{y}.bin"
base_lotpack = "world_{x}_{y}.lotpack"

start_x = 100
start_y = 0
copyLoop(base_lotheader)
copyLoop(base_chunkdata)
copyLoop(base_lotpack)


start_x = 100
start_y = 1
copyLoop(base_lotheader)
copyLoop(base_chunkdata)
copyLoop(base_lotpack)

start_x = 101
start_y = 0
copyLoop(base_lotheader)
copyLoop(base_chunkdata)
copyLoop(base_lotpack)

start_x = 101
start_y = 1
copyLoop(base_lotheader)
copyLoop(base_chunkdata)
copyLoop(base_lotpack)


start_x = 102
start_y = 0
copyLoop(base_lotheader)
copyLoop(base_chunkdata)
copyLoop(base_lotpack)

start_x = 102
start_y = 1
copyLoop(base_lotheader)
copyLoop(base_chunkdata)
copyLoop(base_lotpack)


start_x = 103
start_y = 0
copyLoop(base_lotheader)
copyLoop(base_chunkdata)
copyLoop(base_lotpack)


start_x = 103
start_y = 1
copyLoop(base_lotheader)
copyLoop(base_chunkdata)
copyLoop(base_lotpack)
