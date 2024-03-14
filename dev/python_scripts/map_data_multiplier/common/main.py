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


class MapDataMultiplier():

    def __init__(self, name : str, start_x : int, start_y : int, end_x : int, end_y : int):
        self.name = name

        self.input_path = BASE_INPUT_PATH / name
        self.output_path = BASE_OUTPUT_PATH / name
        self.temp_path = BASE_TEMP_PATH / name

        if not os.path.exists(self.output_path):
            os.makedirs(self.output_path)
        if not os.path.exists(self.temp_path):
            os.makedirs(self.temp_path)

        self.start_x = start_x
        self.start_y = start_y
        self.end_x = end_x
        self.end_y = end_y


    def __copy_loop__(self, base_string):
        original_file = base_string.format(x=self.start_x, y=self.start_y)
        original_file_path = self.input_path / original_file
        print("Copy Loop: " + base_string)
        print("original_file: " + original_file)
        print("original_file_path: " + str(original_file_path))

        for x in range(self.start_x, self.end_x + 1):
            for y in range(self.start_y, self.end_y + 1):

                curr_file = base_string.format(x=x, y=y)
                curr_file_path = self.output_path / curr_file
                shutil.copyfile(original_file_path, curr_file_path)


    def run(self):
        self.__copy_loop__(BASE_LOTHEADER)
        self.__copy_loop__(BASE_CHUNKDATA)
        self.__copy_loop__(BASE_LOTPACK)


