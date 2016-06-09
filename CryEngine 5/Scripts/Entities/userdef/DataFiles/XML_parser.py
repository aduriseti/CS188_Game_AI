import xml.etree.ElementTree as ET
import math;
import sys;
import time;

logging_radius = 10;
logging_diam = 2*logging_radius + 1; # 1 for the mouse size
mouse_offset = logging_radius;

def print_locality(local_arr):
	for y in reversed(range(len(local_arr))):
		for x in range(0, len(local_arr[y])):
			sys.stdout.write(str(local_arr[x][y]) + " ");
		sys.stdout.write("\n");
	sys.stdout.flush()
	
def pos_to_heatmap_xy(obj_loc, mouse_loc):
	return [
		int(obj_loc[0] - mouse_loc[0]) + mouse_offset,
		int(obj_loc[1] - mouse_loc[1]) + mouse_offset
	];
	
def non_zero_coords(obj_loc):
	for coord in obj_loc:
		if coord != 0:
			return True;
	return False;
	
def in_heatmap_bounds(heatmap_xy):
	if (heatmap_xy[0] >= 0 and heatmap_xy[0] < logging_diam and 
			heatmap_xy[1] >= 0 and heatmap_xy[1] < logging_diam):
		return True;
	else:
		return False;
		
def interesting_frame(frame):
	mouse_loc = frame["MouseLocCur"];
	food_loc = frame["FoodLoc"];
	snake_loc = frame["SnakeLoc"];
	trap_loc = frame["TrapLoc"];
	
	locality = [['.' for x in range(logging_diam)] for y in range(logging_diam)];
	
	mouse_heatmap_xy = pos_to_heatmap_xy(mouse_loc, mouse_loc);
	#print mouse_heatmap_xy;
	locality[mouse_heatmap_xy[0]][mouse_heatmap_xy[0]] = 'M';
	
	if non_zero_coords(food_loc):
		food_heatmap_xy = pos_to_heatmap_xy(food_loc, mouse_loc);
		if in_heatmap_bounds(food_heatmap_xy):
			return True;
	
	if non_zero_coords(trap_loc):
		trap_heatmap_xy = pos_to_heatmap_xy(trap_loc, mouse_loc);
		if in_heatmap_bounds(trap_heatmap_xy):
			return True;
			
	if non_zero_coords(snake_loc):
		snake_heatmap_xy = pos_to_heatmap_xy(snake_loc, mouse_loc);
		if in_heatmap_bounds(snake_heatmap_xy):
			return True;
	
def draw_frame(frame):
	mouse_loc = frame["MouseLocCur"];
	food_loc = frame["FoodLoc"];
	snake_loc = frame["SnakeLoc"];
	trap_loc = frame["TrapLoc"];
	
	locality = [['.' for x in range(logging_diam)] for y in range(logging_diam)];
	
	mouse_heatmap_xy = pos_to_heatmap_xy(mouse_loc, mouse_loc);
	#print mouse_heatmap_xy;
	locality[mouse_heatmap_xy[0]][mouse_heatmap_xy[0]] = 'M';
	
	if non_zero_coords(food_loc):
		food_heatmap_xy = pos_to_heatmap_xy(food_loc, mouse_loc);
		if in_heatmap_bounds(food_heatmap_xy):
			locality[food_heatmap_xy[0]][food_heatmap_xy[1]] = 'F'
	
	if non_zero_coords(trap_loc):
		trap_heatmap_xy = pos_to_heatmap_xy(trap_loc, mouse_loc);
		if in_heatmap_bounds(trap_heatmap_xy):
			locality[trap_heatmap_xy[0]][trap_heatmap_xy[1]] = 'T'
			
	if non_zero_coords(snake_loc):
		snake_heatmap_xy = pos_to_heatmap_xy(snake_loc, mouse_loc);
		if in_heatmap_bounds(snake_heatmap_xy):
			locality[snake_heatmap_xy[0]][snake_heatmap_xy[1]] = 'S'

	print_locality(locality);
	

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
	if interesting_frame(frame):
		draw_frame(frame);
		time.sleep(0.4);
	
			
	

		