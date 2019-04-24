extends Sprite

var MoveAction = load("res://scripts/AgentActionSystem/MoveAction.gd")

var enabled = false

onready var Finder = get_node("/root/ObjectFinder") # Finder global
onready var agent = $"../../../Char"
onready var map = Finder.get_node_from_root("Root/Map")
onready var path = $"../../PlayerControlledPath"
onready var action_queue = $"../../ActionQueue"


func _ready():
	set_enabled(false)

func _input(event):
	if enabled:
		if event.is_action_pressed("move_up"):
			move_one_cell(Vector2.UP)
		elif event.is_action_pressed("move_right"):
			move_one_cell(Vector2.RIGHT)
		elif event.is_action_pressed("move_down"):
			move_one_cell(Vector2.DOWN)
		elif event.is_action_pressed("move_left"):
			move_one_cell(Vector2.LEFT)

func reset_position():
	position = Vector2() # position is relative; (0, 0) is on parent

# param dir: unit vector for direction (Vector2.RIGHT, Vector2.LEFT, etc)
func move_one_cell(direction: Vector2):
	var next_pos = agent.position + position + direction * map.cell_size # position where agent would move
	if is_walkable(next_pos):
		position = next_pos - agent.position # position of this sprite (relative to where agent currently is)
		agent.queue_move_action(direction) # add to action queue

# set visibility and reset position
func set_enabled(enabled):
	reset_position()
	self.enabled = enabled
	visible = enabled

func is_walkable(next_position):
	# don't allow moving out of bounds
	# don't allow moving outside of agent movable tiles
	var walkable_cells = path.get_agent_walkable_cell_coords() # todo: cache this in PlayerControlledPath
	var destination_cell = map.world_to_mapa(next_position)

	return destination_cell in walkable_cells
