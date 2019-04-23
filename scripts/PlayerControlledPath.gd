extends Node

var AttackMatrix = load("res://scripts/AttackMatrix.gd")

onready var agent = get_parent()
onready var owner_name = agent.get_name()
onready var walk_distance: int = agent.walk_distance
onready var attack_map = $"../../../AttackMap"
onready var map = agent.map

var walk_matrix # AttackMatrix

func _ready():
	# todo: dont hard code this, generate it from agent walk distance
	walk_matrix = AttackMatrix.new([
		0, 0, 0, 2, 0, 0, 0,
		0, 0, 2, 2, 2, 0, 0,
		0, 2, 2, 2, 2, 2, 0,
		2, 2, 2, 1, 2, 2, 2,
		0, 2, 2, 2, 2, 2, 0,
		0, 0, 2, 2, 2, 0, 0,
		0, 0, 0, 2, 0, 0, 0
	])
	

# color the tiles that can be walked to 
func draw_walkable(agent_cell_coords):
	var cell_coords = walk_matrix.to_world_coords(agent_cell_coords)
	
	for coords in cell_coords:
		attack_map.set_cell(coords[0], coords[1], attack_map.TILES.AGENT_CAN_MOVE_HERE, owner_name) # x, y, tile_index, owner = null,

func draw_path():
	pass
#	var point_start = _point_path[0]
#	var point_end = _point_path[len(_point_path) - 1]
#
#	var last_point = grid.map_to_world(Vector2(point_start.x, point_start.y)) + grid._half_cell_size
#	for index in range(1, len(_point_path)):
#		var current_point = grid.map_to_world(Vector2(_point_path[index].x, _point_path[index].y)) + grid._half_cell_size
#		draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
#		draw_circle(current_point, BASE_LINE_WIDTH * 2.0, DRAW_COLOR)
#		last_point = current_point

# returns: list of Vector2: world coordinates the agent can travel to sequentially to get to world_end
func get_path_relative(start, end):
	pass

func _on_PlayerChar_agent_enters_walk_mode(origin_cell_coords):
	draw_walkable(origin_cell_coords)

func _on_Char_agent_exits_walk_mode(cell_coords):
	attack_map.clear_cells(get_parent().get_name(), attack_map.TILES.AGENT_CAN_MOVE_HERE)

func get_agent_walkable_cell_coords(): # get the list of cell coords (lists) that the agent can walk to
	return walk_matrix.to_world_coords(agent.get_cell_coords())