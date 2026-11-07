extends Area2D

@export var character_data: CharacterData
@export var radius: float = 20.0
@export var npc_color: Color = Color(0.7, 0.2, 0.25)
@export_enum("Both", "Day", "Night")
var active_phase: String = "Night"

enum NPCRole {ROAMING_GUARD, CASTLE_GUARD, BANE}
@export var npc_role: NPCRole = NPCRole.ROAMING_GUARD

var current_health: int
var max_health: int
var fight: int
var coordinates: Vector2i = Vector2i.ZERO
var turn_priority: int = 0
var is_moving: bool = false


func _ready() -> void:
	z_index = 10
	var points = PackedVector2Array()
	
	for i in range(20):
		var angle = deg_to_rad(i * 360.0 / 20.0)
		points.append(Vector2(cos(angle), sin (angle)) * radius)
		
	$Polygon2D.polygon = points
	$Polygon2D.color = npc_color
	
	initialize_character()
	
func initialize_character() -> void:
	if character_data == null:
		push_warning("no shit bruh")
		return
		
	max_health = character_data.body
	current_health = max_health
	fight = character_data.fight
	
	print("=== NPC Initialised ===")
	print("Name: ", character_data.character_name)
	print("Fight: ", fight)
	print("Health: ", current_health, "/", max_health)


func can_act_during_phase(is_night: bool) -> bool:
	if active_phase == "Both":
		return true
	
	if is_night:
		return active_phase == "Night"
		
	return active_phase == "Day"


func take_turn(game: Node) -> void:
	print("NPC taking turn: ", NPCRole.keys()[npc_role])
	
	match npc_role:
		NPCRole.ROAMING_GUARD:
			await roam(game)
			
		NPCRole.CASTLE_GUARD:
			print("Castle Guard no behavior yet")
			
		NPCRole.BANE:
			print("Bane no behavior yet")

func roam(game: Node) -> void:
	var possible_moves: Array[Vector2i] = []
	var neighbors = game.map_manager.get_neighbors(coordinates)
	var occupied = game.map_manager.get_occupied_coordinates(self)
	
	for destination in neighbors:
		if not game.map_manager.hex_tiles.has(destination):
			continue
		
		if destination in occupied:
			continue
		
		possible_moves.append(destination)
	
	if possible_moves.is_empty():
		print("no moves bruh")
		return
	
	var destination = possible_moves.pick_random()
	
	print("Roaming Guard moving to: ", destination)
	
	var moved = await game.movement_manager.move_entity(
		self,
		destination,
		game.map_manager
	)
	
	if not moved:
		print("Roaming Guard no move to do")
