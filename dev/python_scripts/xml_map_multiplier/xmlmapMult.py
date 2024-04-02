import xml.etree.ElementTree as ET
import copy
from pathlib import Path

start_x = 0
start_y = 0

# max_x = 40
# max_y = 20
c_path = Path(__file__).parent

input_path = c_path / "input.xml"
output_path = c_path / "output.xml"

tree = ET.parse(input_path)
root = tree.getroot()


new_childs = []

for addedY in range(0, 10):
    new_y = addedY*3
    for addedX in range(0, 10):
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



with open(output_path, 'wb') as f:
    tree.write(f)
