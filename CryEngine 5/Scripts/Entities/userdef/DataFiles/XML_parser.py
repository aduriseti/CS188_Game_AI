import xml.etree.ElementTree as ET
import math;
import sys;

logging_radius = 10;
logging_diam = 2*logging_radius + 1; # 1 for the mouse size

def print_locality(local_arr):
	for y in reversed(range(len(local_arr))):
		for x in range(0, len(local_arr[y])):
			sys.stdout.write(str(locality[x][y]) + " ");
		sys.stdout.write("\n");
	sys.stdout.flush()

tree = ET.parse("MousePlayer_Data_File_FirstRun_Map3.xml");

root = tree.getroot();

loc_table = root;


while len(loc_table) is 1:
	for child in loc_table:
		loc_table = child;
		print loc_table.tag;

food_encounters = [];
trap_encounters = [];
food_snake_encounters = [];
food_trap_encounters = [];
food_trap_snake_encounters = [];
snake_trap_encounters = [];

#convert all this shit to float
loc_list = [];
for el in loc_table:
	#print el;
	#print el.attrib
	frame_loc_table = {};
	
	for prop in el.attrib:
		if prop == "TrapType" or prop == "FoodType" or prop == "Time":
			continue;
		#print prop;
		loc_str = el.attrib[prop];
		#print loc_str;
		loc_str_list = loc_str.split(',');
		#print loc_str_list;
		loc = [];
		for coord_str in loc_str_list:
			loc.append(float(coord_str));
		#print loc;
		frame_loc_table[prop] = loc;
		
	loc_list.append(frame_loc_table);


for frame in loc_list:

'''
	food_nonzero_coord = 0;
	food_loc = frame["FoodLoc"];
	for coord in food_loc:
		#print coord;
		if coord != 0:
			food_nonzero_coord = coord;
			break
	
	snake_nonzero_coord = 0;
	snake_loc = frame["SnakeLoc"];
	#snake_loc = int)
	for coord in snake_loc:
		#print coord;
		if coord != 0:
			snake_nonzero_coord = coord;
			break;
	
	trap_nonzero_coord = 0;
	trap_loc = frame["TrapLoc"];
	for coord in trap_loc:
		#print coord;
		if coord != 0:
			trap_nonzero_coord = coord;
			break;
'''
			
	
		
locality = [[0 for x in range(logging_diam)] for y in range(logging_diam)];
locality[10][10] = 'M';




#print locality;
print_locality(locality);

		