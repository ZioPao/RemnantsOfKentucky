from pathlib import Path
import shutil
import os

BASE_LOTHEADER = "{x}_{y}.lotheader"
BASE_CHUNKDATA = "chunkdata_{x}_{y}.bin"
BASE_LOTPACK = "world_{x}_{y}.lotpack"

C_PATH = Path(__file__).parent.parent

BASE_INPUT_PATH = C_PATH / "input"
BASE_OUTPUT_PATH = C_PATH / "output"
BASE_TEMP_PATH = C_PATH / "temp"


"""
    x = { start = 0, end = 5 }
    y = { start = 0, end = 2}


    ]


"""
"""
# We're assuming that the files have a similiar format in input

    0_0 1_0 2_0
    0_1 1_1 2_1

"""


class MapDataMultiplier():


    def __init__(self, name : str, x_len : int, y_len : int, x_rep : int, y_rep : int, buffer_x : int, buffer_y : int):
        
        self.name = name

        self.input_path = BASE_INPUT_PATH / name
        self.output_path = BASE_OUTPUT_PATH / name
        self.temp_path = BASE_TEMP_PATH / name
        
        if not os.path.exists(self.output_path):
            os.makedirs(self.output_path)
        if not os.path.exists(self.temp_path):
            os.makedirs(self.temp_path)

        self.x_len = x_len
        self.y_len = y_len

        self.x_rep = x_rep
        self.y_rep = y_rep

        self.buffer_x = buffer_x
        self.buffer_y = buffer_y



    def __convert_file__(self, base_string, x, y):
        og_file = base_string.format(x=x, y=y)
        og_file_path =  self.input_path / og_file
        copied_file = base_string.format(x=self.start_x + x, y=self.start_y + y)
        copied_file_path = self.temp_path / copied_file
        shutil.copyfile(og_file_path, copied_file_path)

    def convert(self, og_start_x, og_start_y):

        og_end_x = og_start_x * self.x_len
        og_end_y = og_start_y * self.y_len

        
        for x in range(og_start_x, og_end_x + 1):
            for y in range(og_start_y, og_end_y + 1):

                self.__convert_file__(BASE_LOTHEADER, x, y)
                self.__convert_file__(BASE_CHUNKDATA, x, y)
                self.__convert_file__(BASE_LOTPACK, x, y)


        # Switch input path
        self.input_path = self.temp_path

    def __copy_loop__(self, base_string, start_x, start_y):
        end_x = start_x + self.x_len + 1
        end_y = start_y + self.y_len + 1

        print(f"end_x = {end_x}")
        print(f"end_y = {end_y}")


        for x_rep in range(0, self.x_rep):
            x_inc = (x_rep + self.buffer_x) * (self.x_len + 1)

            for y_rep in range(0, self.y_rep):
                y_inc = (y_rep + self.buffer_y) * (self.y_len + 1)

                for x in range(start_x, end_x):
                    for y in range(start_y, end_y) :
                        mod_x = x + x_inc
                        mod_y = y + y_inc

                        og_file = base_string.format(x=x, y=y)
                        og_file_path = self.input_path / og_file

                        print(f"{x}-{y} => {mod_x}-{mod_y}")
                        curr_file = base_string.format(x=mod_x, y=mod_y)
                        curr_file_path = self.output_path / curr_file
                        shutil.copyfile(og_file_path, curr_file_path)
                print("_______________________________________")


    def __copy_og_files__(self, base_string):
        for x in range(0, self.x_len+1):
            for y in range(0, self.y_len+1) :
                og_file = base_string.format(x=x, y=y)
                og_file_path = self.input_path / og_file
                copy_file_path = self.output_path / og_file
                shutil.copyfile(og_file_path, copy_file_path)




    def run(self, start_x, start_y):

        # Copy og files
        self.__copy_og_files__(BASE_LOTHEADER)
        self.__copy_og_files__(BASE_CHUNKDATA)
        self.__copy_og_files__(BASE_LOTPACK)
        

        self.__copy_loop__(BASE_LOTHEADER, start_x, start_y)
        self.__copy_loop__(BASE_CHUNKDATA, start_x, start_y)
        self.__copy_loop__(BASE_LOTPACK, start_x, start_y)


