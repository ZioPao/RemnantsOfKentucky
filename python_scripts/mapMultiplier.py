import shutil
import os

# TODO placeholders
start_x = 1
start_y = 1

max_x = 100
max_y = 100

inc_x = 10
inc_y = 20

cwd = os.getcwd()

input_dir = os.path.join(cwd, "python_scripts", "input")
output_dir = os.path.join(cwd, "python_scripts", "output")

if not os.path.exists(output_dir):
    os.mkdir(output_dir)


def copyLoop(base_string):
    original_file = base_string.format(x=start_x, y=start_y)
    original_file_path = os.path.join(input_dir, original_file)

    curr_x = 0
    curr_y = 0

    for x in range(start_x + inc_x, max_x, inc_x):
        for y in range(start_y + inc_y, max_y, inc_y):

            curr_x = curr_x + x
            curr_y = curr_y + y
            curr_file = base_string.format(x=curr_x, y=curr_y)
            curr_file_path = os.path.join(output_dir, curr_file)
            
            shutil.copyfile(original_file_path, curr_file_path)

############################
base_lotheader = "{x}_{y}.lotheader"
base_chunkdata = "chunkdata_{x}_{y}.bin"
base_lotpack = "world_{x}_{y}.lotpack"

copyLoop(base_lotheader)
copyLoop(base_chunkdata)
copyLoop(base_lotpack)