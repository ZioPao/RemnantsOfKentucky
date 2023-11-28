#Based on https://github.com/Orcicorn-ProjectZomboid/ResetMapChunks

# Clean maps before starting it up

# Starts server normally

from os import listdir, remove
from os.path import split as join 

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

    # TODO Exception for 100 x 100 and nearby

    return (int(X) >= int(startX)) and (int(X) <= int(endX)) and \
           (int(Y) >= int(startY)) and (int(Y) <= int(endY))

def reset_instances(path):
    files = listdir(path)
    counter = 0

    start_X = 3000
    start_Y = 3000
    end_X = 3100
    end_Y = 3100

    for file in files:
        #print(file)
        current_item = file[:-4].split('_')

        if len(current_item) == 3:
            type = current_item[0]
            if type == 'map' or type == 'chunkdata' or type == 'zpop':
                #print("checking boundary")
                if not in_boundary(current_item[1], current_item[2], start_X, start_Y, end_X, end_Y):
                    counter += 1
                    remove(join(path, file))
                    print("Removed " + file)
    print("Removed " + str(counter) + " in total" )

################################


# TEST PATH C:\Users\...\Zomboid\Saves\Multiplayer\pzeft
#t_path = #

#reset_instances(t_path)