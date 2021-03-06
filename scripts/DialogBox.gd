extends RichTextLabel

# Declare member variables here. Examples:
onready var scene_manager = get_node("/root/SceneManager")
onready var turn_timer = get_tree().get_root().get_node("Root/TurnManager/TurnTimer")
onready var player_input_manager = get_tree().get_root().get_node("Root/PlayerInputManager")
onready var combat_ui = get_tree().get_root().get_node("Root/GeneralCamera/CombatUI/QueueListRect")

var dialog = ["This is 6 second RPG created by Gridventure", "This dialog will serve as a little tutorial", "There are 2 player controlled characters on the map. You can switch control between them sung the Switch Control button in the top left.","A turn is comprised of 3 stages. You may end a turn using the End Turn button in the top left.", "There are two types of actions one may do: move and attack. Movement is done via clicking anywhere on the map. Attacking is done by clicking on one of the three attack type buttons and selecting a direction.", "There are three stages to each turn:\n 1. Move\n2. Move or Attack\n3.Move", "Each player can take 5 hits before dying. Take turns inputing input for both characters to see who wins!", "Enjoy the game!"]
var page = 0
var isDone = false
onready var DialogBox = get_parent()
onready var label = DialogBox.get_node("Label")

# Called when the node enters the scene tree for the first time.
func _ready(): 
	if scene_manager.dialog != null:
		dialog = scene_manager.dialog
	
	turn_timer.pause()
	combat_ui.visible = false
	set_bbcode(dialog[page])
	set_visible_characters(0)
	set_process_input(true)
	combat_ui.get_parent().enabled = false
	player_input_manager.enabled = false
	isDone = false

func _process(delta):
	if get_visible_characters() < get_total_character_count():
		label.text = "Press any key to skip"
	else:
		label.text = "Press any key to continue"

func _input(event):
	
	if event is InputEventKey or event is InputEventMouseButton:
		if event.pressed:
			if isDone and DialogBox.visible:
				combat_ui.visible = true
				turn_timer.resume()
				set_process_input(false)
				combat_ui.get_parent().enabled = true
				player_input_manager.enabled = true
				DialogBox.visible = false
			else:
				if get_visible_characters() > get_total_character_count():
					if page < dialog.size() - 1:
						page += 1
						set_bbcode(dialog[page])
						set_visible_characters(0)
					else:
						isDone = true
				else:
					set_visible_characters(get_total_character_count())

func _on_Timer_timeout():
	set_visible_characters(get_visible_characters() + 1)
	
	if get_visible_characters() > get_total_character_count():
		if page >= dialog.size() - 1:
			isDone = true
