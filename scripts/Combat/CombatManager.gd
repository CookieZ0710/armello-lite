extends Node

var combat_active: bool = false

var attacker: Node = null
var defender: Node = null

@onready var combat_screen = $"../CanvasLayer/CombatScreen"

func _ready() -> void:
	combat_screen.return_requested.connect(end_combat)
	
func begin_combat(new_attacker: Node, new_defender: Node) -> void:
	if combat_active:
		return
		
	if not is_instance_valid(new_attacker):
		return
	
	if not is_instance_valid(new_defender):
		return

	attacker = new_attacker
	defender = new_defender
	
	combat_active = true
	
	print("=== Combat Initiated ===")
	print("Attacker: ", attacker.character_data.character_name)
	print("Defender: ", defender.character_data.character_name)
	
	combat_screen.show_encounter(attacker, defender)
	
func end_combat() -> void:
		if not combat_active:
			return
			
		print("=== Combat Ended ===")
		
		combat_screen.hide()
		
		attacker = null
		defender = null
		
		combat_active = false
