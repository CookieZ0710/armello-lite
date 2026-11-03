extends Node2D

const PLAYER = preload("res://scenes/Player.tscn")
const DEFAULT_HERO = preload("res://data/characters/default_hero.tres")

const NPC = preload("res://scenes/NPC.tscn")
const NPC_SCRIPT = preload("res://scripts/entities/npc.gd")
const BANE_DATA = preload("res://data/characters/placeholder_bane.tres")
const GUARD_DATA = preload("res://data/characters/royal_guard.tres")


var player								# player
var player_coordinates = Vector2i(2, 2) # spawn point
var bane
var guard

@onready var map_manager = $MapManager
@onready var movement_manager = $MovementManager
@onready var turn_manager = $TurnManager
@onready var turn_order_bar:HBoxContainer = $CanvasLayer/TurnOrderBar
		

func _ready() -> void:
	randomize()
	
	map_manager.generate_map()		# make hex tiles
	map_manager.center_map()		# check and move to mid of tiles
	
	map_manager.tile_clicked.connect(_on_tile_clicked)
	
	$CanvasLayer/EndTurnButton.pressed.connect(
		_on_end_turn_button_pressed
	)
	
	player_coordinates = map_manager.offset_to_axial(2, 2)
	create_player()		# add player
	#spawn_bane()
	#spawn_guard()
	
	var castle_spawn = map_manager.get_random_type(map_manager.CASTLE_DATA)
	if castle_spawn.x != 999999:
		spawn_guard(castle_spawn, NPC_SCRIPT.NPCRole.CASTLE_GUARD)
	
	
	for i in range(2): 
		var random_spawn = map_manager.get_random_tile()
		if random_spawn.x == 999999:
			break
		spawn_guard(random_spawn, NPC_SCRIPT.NPCRole.ROAMING_GUARD)
	
	turn_manager.turn_changed.connect(_on_turn_changed)
	turn_manager.phase_changed.connect(_on_phase_changed)
	turn_manager.queue_changed.connect(update_turn_order_ui)
	
	turn_manager.start_queue()
	update_turn_order_ui()



func create_player(): 
	player = PLAYER.instantiate()
	player.character_data = DEFAULT_HERO
	player.coordinates = player_coordinates
	
	add_child(player)
	player.position = map_manager.hex_tiles[player_coordinates].position
	
	#map_manager.player = player
	turn_manager.register_actor(player)


func spawn_bane(spawn_coordinates: Vector2i) -> void:
	if not map_manager.hex_tiles.has(spawn_coordinates):
		push_warning("Invalid Bane spawn coordinate!")
		return

	if map_manager.get_occupied_coordinates().has(spawn_coordinates):
		push_warning("Bane spawn tile is occupied!")
		return
		
	var new_bane = NPC.instantiate()
	new_bane.character_data = BANE_DATA
	new_bane.active_phase = "Night"
	new_bane.npc_color = Color(0.478, 0.152, 0.595, 1.0)
	new_bane.npc_role = NPC_SCRIPT.NPCRole.BANE
	new_bane.coordinates = spawn_coordinates
	
	add_child(new_bane)
	new_bane.position = map_manager.hex_tiles[spawn_coordinates].position
	
	turn_manager.register_actor(new_bane)


func spawn_guard(spawn_coordinates: Vector2i, role: NPC_SCRIPT.NPCRole) -> void:
	if not map_manager.hex_tiles.has(spawn_coordinates):
		push_warning("Invalid Guard spawn coordinate!")
		return

	if map_manager.get_occupied_coordinates().has(spawn_coordinates):
		push_warning("Guard spawn tile is occupied!")
		return
		
	var new_guard = NPC.instantiate()
	new_guard.character_data = GUARD_DATA
	new_guard.active_phase = "Day"
	new_guard.npc_color = Color(0.864, 0.71, 0.0, 1.0)
	new_guard.npc_role = role
	new_guard.coordinates = spawn_coordinates
	
	add_child(new_guard)
	new_guard.position = map_manager.hex_tiles[spawn_coordinates].position
	
	turn_manager.register_actor(new_guard)


func move_player(new_coordinates: Vector2i) -> void:
	var moved = movement_manager.move_entity(
		player,
		new_coordinates,
		map_manager
	)
	
	if not moved:
		return
	
	player_coordinates = player.coordinates

func update_turn_order_ui() -> void:
	for child in turn_order_bar.get_children():
		child.queue_free()
	
	for i in range(turn_manager.turn_queue.size()):
		var actor= turn_manager.turn_queue[i]
		var square = ColorRect.new()
		
		square.custom_minimum_size = Vector2(40, 40)
		square.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		if actor == player:
			square.color = Color(0.2, 0.45, 0.95)
		elif actor == bane:
			square.color = Color(0.694, 0.312, 0.84, 1.0)
		elif actor == guard:
			square.color = Color(0.864, 0.71, 0.0, 1.0)
		
		if turn_manager.has_finished_turn(actor):
			square.modulate = Color(0.35, 0.35, 0.35, 0.7)
			
		#elif actor == turn_manager.current_actor:
			#square.modulate = Color(1.0, 1.0, 1.0, 1.0)
			#square.color = square.color.lightened(0.35)
		
		turn_order_bar.add_child(square)

func _on_turn_changed(actor: Node) -> void:
	if actor == player:
		print("=== Player's Turn ===")
	elif actor.npc_role == NPC_SCRIPT.NPCRole.BANE:
		print("=== Bane's Turn ===")
		print("Bane cant do shit so pass")
	elif actor.npc_role == NPC_SCRIPT.NPCRole.CASTLE_GUARD:
		print("=== Castle Guard's Turn ===")
		print("Guard cant do shit so pass")
	elif actor.npc_role == NPC_SCRIPT.NPCRole.ROAMING_GUARD:
		print("=== Roaming Guard's Turn ===")
		print("Guard cant do shit so pass")
	
	update_turn_order_ui()


# check if tile can move
func _on_tile_clicked(clicked_coordinates: Vector2i) -> void:
	if turn_manager.current_actor != player:
		print("not ur turn yet bitch")
		return
	
	move_player(clicked_coordinates)

func _on_end_turn_button_pressed() -> void:
	turn_manager.end_turn()

func _on_phase_changed(night: bool) -> void:
	$CanvasLayer/NightOverlay.visible = night
	
	if night:
		print("Night has fallen!")
		
		var ruin_spawn = map_manager.get_random_type(map_manager.RUINS_DATA)
		if ruin_spawn.x != 999999:
			spawn_bane(ruin_spawn)
	else:
		print("Day has begun!")
	
	update_turn_order_ui()
