#Based on https://github.com/Orcicorn-ProjectZomboid/ResetMapChunks
# Clean maps before starting it up
# Starts server normally

from os import listdir, remove, getcwd
from os.path import split as path_split, abspath, join, isfile
from pathlib import Path
import subprocess
import json

def in_boundary(X, Y, startX, startY, endX, endY):
    """Determines if a co-ordinate is within a boundary

    Args:
        X (int): The X co-ordinate to test
        Y (int): The Y co-ordinate to test
        startX (int): The starting boundary (top-left) X co-ordinate
        startY (int): The starting boundary Y co-ordinate
        endX (int): The stopping boundary (bottom-right) X co-ordinate
        endY (int): The stopping boundary Y co-ordinate

    Returns:
        boolean: Is the defined X,Y within the boundaries of Start/Stop
    """

    return (int(X) >= int(startX)) and (int(X) <= int(endX)) and \
           (int(Y) >= int(startY)) and (int(Y) <= int(endY))

def reset_instances(path):
    files = listdir(path)
    counter = 0

    # map_x_y => x*300, y*300


    # FIXED NUMBERS FOR REWORK!!
    start_X = 0
    start_Y = 0
    end_X = 600
    end_Y = 100

    for file in files:
        #print(file)
        current_item = file[:-4].split('_')
        if len(current_item) == 3:
            type = current_item[0]
            if type == 'map' or type == 'chunkdata' or type == 'zpop':
                #print("checking boundary")
                if in_boundary(current_item[1], current_item[2], start_X, start_Y, end_X, end_Y):
                    counter += 1
                    # print(path)
                    # print(file)

                    remove(Path(path) / file)
                    print("Removed " + file)
    print("Removed " + str(counter) + " in total" )

################################

# Load json
config_path = Path(__file__).parent / 'config.json'

with open(config_path) as config_data:
    data = json.load(config_data)

# Reset map files
save_path = data.get("savePath")
reset_instances(save_path)

# Run the actual server
#sh_path = data.get("serverStartPath")
#subprocess.call(['sh', sh_path])