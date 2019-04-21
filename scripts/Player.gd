extends KinematicBody2D

export(float) var SPEED = 200.0
export(int) var hp = 4

# idle is waiting for player input, wait is waiting for turn to end or player to complete action ?, turn indicates it's this player reads inputs & not the other
enum STATES { IDLE, WAIT, TURN } 
var _state = null

var is_attack_turn = false
var path = []
var target_point_world = Vector2()
var target_position = Vector2()
var attack_mode = null
var attack_dir = Vector2()
var direction = Vector2()

const Top = Vector2(0,-1)
const Right = Vector2(1,0)
const Down = Vector2(0,1)
const Left = Vector2(-1,0)
var cell_size = 64

onready var attack_template = get_tree().get_root().get_node("Root/AttackTemplate")
onready var selection_manager = get_tree().get_root().get_node("Root/SelectionManager")
onready var turn_manager = get_tree().get_root().get_node("Root/TurnManager")
onready var map = get_tree().get_root().get_node("Root/Map")
onready var attack_map = $"../../AttackMap"
onready var pathing = get_parent().get_node("Path")
var type

var dragging = false

var is_moving = false
var target_pos = Vector2()
var target_dir = Vector2()

var speed = 0
const Max_speed = 400

var velocity = Vector2()

func _ready():
	_change_state(STATES.IDLE)
	set_process_input(true)
	set_physics_process(true)
	

func get_position():
	return position


func get_cell_coords():
	# get world position, size of individual cell, divide & truncate
	var x = int(position.x / map.cell_size.x)
	var y = int(position.y / map.cell_size.y)
	return Vector2(x, y)
	

func _change_state(new_state):
	if new_state == STATES.WAIT:
		path = pathing.get_path_relative(position, target_position)
		if not path or len(path) == 1:
			_change_state(STATES.IDLE)
			return
		# The index 0 is the starting cell
		# we don't want the character to move back to it in this example
		target_point_world = path[1]
	_state = new_state

func take_damage():
	hp = hp - 1

func render_hp():
	if hp >= 0:
		$Label.text = "HP: "
		for i in range(0, hp):
			$Label.text+= "O "
		for i in range(0, 4-hp):
			$Label.text+= "X "
	else:
		$Label.text = "DEAD"

func _process(delta):
	render_hp()
	
	if attack_mode != null and (attack_template.click_mode == null or selection_manager.selected == get_parent()):
		preview_attack(attack_mode, attack_dir, attack_map.TILES.GREEN_ZONE_TO_ATTACK)
	
	if _state != STATES.TURN:
		return
		
	if attack_mode != null and is_attack_turn:
		attack_template.do_attack(get_cell_coords(), attack_mode, attack_dir, self)
		attack_mode = null
		_change_state(STATES.WAIT)
	else:
		var arrived_to_next_point = move_to(target_point_world)
		if arrived_to_next_point:
			_change_state(STATES.WAIT)
			path.remove(0)
			if len(path) == 0:
				_change_state(STATES.IDLE)
				return
			target_point_world = path[0]


func do_turn(is_attack_turn):
	self.is_attack_turn = is_attack_turn
	if _state == STATES.WAIT or attack_mode != null:
		_state = STATES.TURN
	else:
		attack_map.clear()

func _physics_process(delta):
	direction = Vector2()
	speed = 0
	#move_and_slide(target_pos - position)
	
	if not is_moving and direction != Vector2():
		target_dir = direction
		if map.is_cell_empty(position, target_dir):
			target_pos = pathing.update_line()
			is_moving = true
	elif is_moving:
		speed = Max_speed
		velocity = speed * target_dir * delta
		var pos = position
		
		var distance_to_target = pos.distance_to(target_pos)
		var move_distance = velocity.length()
		if move_distance > distance_to_target:
			velocity = target_dir * distance_to_target
			is_moving = false
		distance_to_target = Vector2(abs(target_pos.x - pos.x) , abs(target_pos.y - pos.y))
		if abs(velocity.x) > distance_to_target.x:
			velocity.x = distance_to_target.x * target_dir.x
			is_moving = false
		if abs(velocity.y) > distance_to_target.y:
			velocity.x = distance_to_target.y * target_dir.y
			is_moving = false
		move_and_collide(velocity)


func move_to(world_position):
	var MASS = 10.0
	var ARRIVE_DISTANCE = 10.0

	var desired_velocity = (world_position - position).normalized() * SPEED
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	position += velocity * get_process_delta_time()
	#rotation = velocity.angle()
	return position.distance_to(world_position) < ARRIVE_DISTANCE


func _unhandled_input(event):
	if selection_manager.selected == get_parent() and not Input.is_key_pressed(KEY_CONTROL):
		if event.is_action_pressed('click'):
			if attack_template.click_mode == null:
				if Input.is_key_pressed(KEY_SHIFT):
					global_position = get_global_mouse_position()
				else:
					target_position = get_global_mouse_position()
			else:
				attack_mode = attack_template.click_mode
				attack_dir = $Attack.get_attack_dir_str($Attack.get_relative_attack_dir())
				attack_template.click_mode = null
			_change_state(STATES.WAIT)
		elif event is InputEventMouseMotion and attack_template.click_mode != null:
			var dir_str = $Attack.get_attack_dir_str($Attack.get_relative_attack_dir())
			preview_attack(attack_template.click_mode, dir_str, attack_map.TILES.YELLOW_ZONE_TO_ATTACK)

func preview_attack(attack_template_attack_mode, dir_str, tile_type):
	attack_template.visualize_attack(get_cell_coords(), attack_template_attack_mode, dir_str, self, tile_type)