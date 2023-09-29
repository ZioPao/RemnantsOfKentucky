# maps the whole directory, untested.

import shutil
import os
import glob
import re

start_x = 4
start_y = 2

x_grid_len = 4
y_grid_len = 4

buffer = 1

inc_x = 2 + buffer
inc_y = 3 + buffer

cwd = os.getcwd()

input_dir = os.path.join(cwd, "input")
output_dir = os.path.join(cwd, "output")

if not os.path.exists(output_dir):
    os.mkdir(output_dir)

def extractCoordinates(file_name):
    # Extract x and y values using regular expressions or string manipulations based on your file naming convention
    match = re.match(r"(\d+)_(\d+)", file_name)
    if match:
        x, y = map(int, match.groups())
        return x, y
    return None, None

def copyFiles(file_pattern, base_string):
    files = glob.glob(os.path.join(input_dir, file_pattern))
    for file_path in files:
        file_name = os.path.basename(file_path)
        extracted_x, extracted_y = extractCoordinates(file_name)
        if extracted_x is not None and extracted_y is not None:
            destination_file = base_string.format(x=extracted_x, y=extracted_y)
            destination_path = os.path.join(output_dir, destination_file)
            shutil.copyfile(file_path, destination_path)

base_lotheader = "{x}_{y}.lotheader"
base_chunkdata = "chunkdata_{x}_{y}.bin"
base_lotpack = "world_{x}_{y}.lotpack"

copyFiles("*.lotheader", base_lotheader)
copyFiles("*.bin", base_chunkdata)
copyFiles("*.lotpack", base_lotpack)
