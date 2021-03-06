extends TileMap

export(Vector2) var map_size = Vector2(16, 16)

# last element always needs to be VOID here
enum TILES { ZONE_TO_ATTACK, YELLOW_ZONE_TO_ATTACK, GREEN_ZONE_TO_ATTACK, AGENT_CAN_MOVE_HERE, VOID } 

#onready var Utils = get_node("/root/Utils/")
var Utils = load("res://scripts/globals/Utils.gd")
var GridElement = load("res://scripts/GridElement.gd")

var grid = []
var cell_set_queue = []

onready var reachable_cell_constraint = funcref(self, "reachable_cell_constraint_func") # filter func to return true if cell is reachable by agent


func _ready():
	clear()

func is_outside_map_bounds(point):
	return point[0] < 0 or point[1] < 0 or point[0] >= map_size.x or point[1] >= map_size.y

# param pos: type: Vector2 or list<int> of size 2. grid coordinates in range [0, map.size = 16)
func get_cell_content(pos):
	return grid[pos[0]][pos[1]] 

func _process(delta):
	if not cell_set_queue.empty():
		clear() # remove all tiles from tile map
		for c in cell_set_queue:
			set_cell(c[0],c[1],c[2],c[3],c[4],c[5],c[6],c[7])
		cell_set_queue.clear()

func queue_set_cell(x, y, tile_index, owner = null, flip_x = false, flip_y = false, transpose = false, autotile_coord = Vector2(0, 0)):
		cell_set_queue.append([x, y, tile_index, owner, flip_x, flip_y, transpose, autotile_coord])

# override
func set_cell(x, y, tile_index, owner = null, flip_x = false, flip_y = false, transpose = false, autotile_coord = Vector2(0, 0)):
	if is_outside_map_bounds(Vector2(x, y)):
#		print_debug("Error adding cell " + str(x) + ", " + str(y) + ", " + str(owner) )
		return null
	
	var cell = get_cell_content(Vector2(x, y))
	
	grid[y][x] = GridElement.new("set_cell element", tile_index, owner, [x, y], cell) 
	.set_cell(x, y, tile_index, flip_x, flip_y, transpose, autotile_coord) # call super.set_cell
	
# clear (remove) tiles/cells from map where the cell owner or/and tile_index matches
# param owner: Object or str
func clear_cells(owner = null, tile_index = null):
	if tile_index != null:
		tile_index = int(tile_index)
	if not owner and tile_index == null: # nothing to clear
		print("warning: you called clear_cells without any owner or tile_index, do you mean to call clear() ?")
		return
		
	var cleared_count = 0
	var owner_name = Utils.get_name(owner) # allows for owner to be an Object or a string
	
	for y in range(map_size.y): # ea row
		for x in range(map_size.x): # ea col
			var cell = get_cell_content([x, y])
			var cell_owner_name = Utils.get_name(cell.owner) # ambiguous data type, Object or str
				
			if owner and tile_index != null: # owner and tile_index specified to be cleared
				if cell_owner_name == owner_name and cell.tile_index == tile_index:
					set_cell(x, y, int(TILES.VOID), null)
					cleared_count += 1
			elif owner and cell_owner_name == owner_name: # only cells of owner to be cleared
				 set_cell(x, y, int(TILES.VOID), null)
				 cleared_count += 1
			elif cell.tile_index == tile_index: # only cells of tile_index to be cleared
				 set_cell(x, y, int(TILES.VOID), null)
				 cleared_count += 1
				
	print_debug("tiles cleared: " + str(cleared_count))

# filter func - remove falsey values later down the pipe
func reachable_cell_constraint_func(cell_coord: Array) -> bool:
	# todo: do a* pathing and check to see if cell is on wall/obstacle or walks through a wall
	return not is_outside_map_bounds(cell_coord)
	
func clear():
	grid = []
	for x in range(map_size.x):
		grid.append([])
		for y in range(map_size.y):
			grid[x].append(GridElement.new("void", int(TILES.VOID), null, [x, y])) # ele_name, ele_tile_index, ele_owner, grid_coords, prev_element = null
		
	.clear()