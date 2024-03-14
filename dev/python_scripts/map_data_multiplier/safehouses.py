from pathlib import Path
import shutil
import os


c_path = Path(__file__).parent

input_dir = c_path / "input"
output_dir = c_path / "output"
temp_dir = c_path / "temp"

if not os.path.exists(output_dir):
    os.mkdir(output_dir)
if not os.path.exists(temp_dir):
    os.mkdir(temp_dir)

#########################
BASE_LOTHEADER = "{x}_{y}.lotheader"
BASE_CHUNKDATA = "chunkdata_{x}_{y}.bin"
BASE_LOTPACK = "world_{x}_{y}.lotpack"

start_x = 0
end_x = 0

start_y = 100
end_y = 200

def copy_loop(base_string, start_x, start_y):
    original_file = base_string.format(x=start_x, y=start_y)
    original_file_path = temp_dir / original_file
    print("Copy Loop: " + base_string)
    print("original_file: " + original_file)
    print("original_file_path: " + str(original_file_path))

    for x in range(start_x, end_x + 1):
        for y in range(start_y, end_y + 1):

            curr_file = base_string.format(x=x, y=y)
            curr_file_path = output_dir / curr_file
            shutil.copyfile(original_file_path, curr_file_path)



def run_all_loop(start_x, start_y):
    copy_loop(BASE_LOTHEADER, start_x=start_x, start_y=start_y)
    copy_loop(BASE_CHUNKDATA, start_x=start_x, start_y=start_y)
    copy_loop(BASE_LOTPACK, start_x=start_x, start_y=start_y)


run_all_loop(start_x, start_y)