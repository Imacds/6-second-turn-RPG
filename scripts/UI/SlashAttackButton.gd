extends Button

onready var attack_template = get_tree().get_root().get_node("Root/AttackTemplate")


func _on_SlashAttackButton_pressed():
	attack_template.set_click_mode(attack_template.MODE.SLASH)