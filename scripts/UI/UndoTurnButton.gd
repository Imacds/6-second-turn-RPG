extends Button

onready var attack_template = get_tree().get_root().get_node("Root/AttackTemplate")
onready var selection_manager = get_tree().get_root().get_node("Root/SelectionManager")
onready var attack_map  = get_tree().get_root().get_node("Root/AttackMap")
onready var parent = get_parent().get_parent().get_parent()

func _unhandled_input(event):
	if parent.enabled:
		if Input.is_action_just_pressed("undo"):
			if attack_template.get_click_mode() != null:
				attack_template.set_click_mode(null)
				attack_map.clear()
			else:
				selection_manager.selected.get_node("Char").undo_last_action()

func _on_Undo_pressed():
	if parent.enabled:
		if attack_template.get_click_mode() != null:
			attack_template.set_click_mode(null)
			attack_map.clear()
		else:
			selection_manager.selected.get_node("Char").undo_last_action()
	
