extends Node

const DICE_FACES: Array[String] = [
	"⚔",  # Sword
	"🛡",  # Shield
	"☀",  # Sun
	"☾",  # Moon
	"☠",  # Rot
	"★"   # Wild
]

var combat_active: bool = false

var attacker: Node = null
var defender: Node = null

var combat_context: CombatContext

@onready var combat_screen = $"../CanvasLayer/CombatScreen"
@onready var map_manager = $"../MapManager"
@onready var turn_manager = $"../TurnManager"

func _ready() -> void:
	combat_screen.return_requested.connect(end_combat)
	combat_screen.roll_requested.connect(roll_dice)
	
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
	
	combat_context = CombatContext.new()
	
	calculate_combat()
	
	combat_screen.show_encounter(
		combat_context,
		turn_manager.is_night
	)


func calculate_combat() -> void:
	var context = combat_context
	
	context.attacker = attacker
	context.defender = defender

	context.attacker_fight = attacker.character_data.fight
	context.defender_fight = defender.character_data.fight

	context.attacker_body = attacker.character_data.body
	context.defender_body = defender.character_data.body

	context.attacker_current_health = attacker.current_health
	context.defender_current_health = defender.current_health

	context.attacker_rot = get_character_rot(attacker)
	context.defender_rot = get_character_rot(defender)

	# Compare Rot and allocate bonus dice.
	if context.attacker_rot > context.defender_rot:
		context.attacker_bonus_dice = context.defender_rot

	elif context.defender_rot > context.attacker_rot:
		context.defender_bonus_dice = context.attacker_rot

	# Calculate final dice counts.
	context.attacker_total_dice = (
		context.attacker_fight + context.attacker_bonus_dice
	)

	context.defender_total_dice = (
		context.defender_fight + context.defender_bonus_dice
	)
	
	if map_manager.hex_tiles.has(defender.coordinates):
		var defender_tile = map_manager.hex_tiles[defender.coordinates]
		context.defender_terrain_bonus = defender_tile.tile_data.defence_bonus

	print("=== Combat Calculation ===")
	print("Attacker Fight: ", context.attacker_fight)
	print("Attacker Rot: ", context.attacker_rot)
	print("Attacker Bonus Dice: ", context.attacker_bonus_dice)
	print("Attacker Total Dice: ", context.attacker_total_dice)

	print("Defender Fight: ", context.defender_fight)
	print("Defender Rot: ", context.defender_rot)
	print("Defender Bonus Dice: ", context.defender_bonus_dice)
	print("Defender Total Dice: ", context.defender_total_dice)
	print("Defender Terrain Bonus: ", context.defender_terrain_bonus)


func get_character_rot(character: Node) -> int:
	return character.rot
	

func roll_dice() -> void:
	if not combat_active or combat_context == null:
		return
	
	combat_context.attacker_results.clear()
	combat_context.defender_results.clear()
	
	for i in range(combat_context.attacker_total_dice):
		combat_context.attacker_results.append(
			randi_range(0,5)
		)
	
	for i in range(combat_context.defender_total_dice):
		combat_context.defender_results.append(
			randi_range(0,5)
		)

	await combat_screen.animate_roll(
		combat_context.attacker_results,
		combat_context.defender_results
	)
	
	print("=== Dice Roll Complete ===")
	print("Attacker: ", combat_context.attacker_results)
	print("Defender: ", combat_context.defender_results)
	

func end_combat() -> void:
		if not combat_active:
			return
			
		print("=== Combat Ended ===")
		
		combat_screen.hide()
		
		attacker = null
		defender = null
		combat_context = null
		
		combat_active = false
