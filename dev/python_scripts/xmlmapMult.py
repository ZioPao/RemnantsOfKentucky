import shutil
import os
import xml.etree.ElementTree as ET
import copy




start_x = 50
start_y = 0



# max_x = 40
# max_y = 20

cwd = os.getcwd()
input_dir = os.path.join(cwd, "dev", "python_scripts", "input")
original_file_path = os.path.join(input_dir, 'worldmap_base.xml')
save_file_path = os.path.join(input_dir, 'new_worldmap.xml')

tree = ET.parse(original_file_path)
root = tree.getroot()


# is_start = True
# new_childs = []

# for addedVal in range(1, 10):
#     for y in [0, 1]:
#         for x in [0, 1, 2, 3]:

#             new_x = x + addedVal*4
#             new_y = y
#             print("x " + str(new_x))
#             print("y " + str(new_y))


new_childs = []

for addedY in range(0, 5):
    new_y = addedY*3
    for addedX in range(0, 7):
        new_x = addedX*5 + start_x
        for child in root.iter('cell'):
            print(child.attrib)
            new_element = copy.deepcopy(child)  # Save them in a separate list
            new_element.attrib['x'] = str(int(new_element.attrib['x']) + new_x)
            new_element.attrib['y'] = str(int(new_element.attrib['y']) + new_y)
            # same y for now
            new_childs.append(new_element)
    
for new_child in new_childs:
    root.append(new_child)
new_childs = []
print("______________________")



with open(save_file_path, 'wb') as f:
    tree.write(f)
# for child in root.iter('cell'):
#     new_element = copy.deepcopy(child)  # Save them in a separate list
#     if is_start:
#         child.attrib.x = start_x


#     new_childs.append(new_element)
#     print(child.attrib)

# # def add_cell():
# #     cell = ET.Element('cell')
