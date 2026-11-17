extends Control

signal return_requested

@onready var attacker_name: Label = $Background/MainLayout/Participants/AttackerPanel/AttackerName
@onready var defender_name: Label = $Background/MainLayout/Participants/DefenderPanel/DefenderName
@onready var return_button: Button = $Background/MainLayout/ReturnButton

func _ready() -> void:
	return_button.pressed.connect(
		func(): return_requested.emit()
	)

func show_encounter(attacker: Node, defender: Node) -> void:
	attacker_name.text =get_character_name(attacker)
	defender_name.text =get_character_name(defender)
	
	show()
	
func get_character_name(character: Node) -> String:
	if character.character_data != null:
		return character.character_data.character_name
	
	return character.name
