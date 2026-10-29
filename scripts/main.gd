extends Node2D

const PLAYER = preload("res://scenes/Player.tscn")
const DEFAULT_HERO = preload("res://data/characters/default_hero.tres")

const NPC = preload("res://scenes/NPC.tscn")
const BANE_DATA = preload("res://data/characters/placeholder_bane.tres")
const GUARD_DATA = preload("res://data/characters/royal_guard.tres")

const HEX_TILE = preload("res://scenes/HexTile.tscn")
const GRASS_DATA = preload("res://data/tiles/grass.tres")
const FOREST_DATA = preload("res://data/tiles/forest.tres")
const SWAMP_DATA = preload("res://data/tiles/swamp.tres")
const STONE_DATA = preload("res://data/tiles/stone.tres")
const MOUNTAIN_DATA = preload("res://data/tiles/mountain.tres")
const SETTLEMENT_DATA = preload("res://data/tiles/settlement.tres")
const RUINS_DATA = preload("res://data/tiles/ruins.tres")
const CASTLE_DATA = preload("res://data/tiles/castle.tres")

@export var map_width: int = 8
@export var map_height: int = 9

var player								# player
var player_coordinates = Vector2i(2, 2) # spawn point
var hex_tiles = {}						# our map container
var bane
var guard

@onready var turn_manager = $TurnManager
@onready var turn_order_bar:HBoxContainer = $CanvasLayer/TurnOrderBar
		

func _ready() -> void:
	randomize()
	
	generate_map()		# make hex tiles
	center_map()		# check and move to mid of tiles
	
	$CanvasLayer/EndTurnButton.pressed.connect(
		_on_end_turn_button_pressed
	)
	
	player_coordinates = offset_to_axial(2, 2)
	create_player()		# add player
	#spawn_bane()
	#spawn_guard()
	
	var castle_spawn = get_random_type(CASTLE_DATA)
	spawn_guard(castle_spawn)
	
	for i in range(2): 
		var random_spawn = get_random_tile()
		spawn_guard(random_spawn)
	
	turn_manager.turn_changed.connect(_on_turn_changed)
	turn_manager.phase_changed.connect(_on_phase_changed)
	turn_manager.queue_changed.connect(update_turn_order_ui)
	
	turn_manager.start_queue()
	update_turn_order_ui()


# take normal coord into logical use
func offset_to_axial(col: int, row: int) -> Vector2i:
	@warning_ignore("integer_division")
	var q = col - (row - (row & 1)) / 2
	var r = row
	return Vector2i(q, r)

# logical coord into visual coord
func axial_to_pixel(axial: Vector2i, radius: float) -> Vector2:
	return Vector2(
		radius * sqrt(3) * (axial.x + axial.y / 2.0),
		radius * 1.5 * axial.y
	)

# makes the hex tiles based on the map size
func generate_map():
	for row in range(map_height):
		var row_width = map_width if row % 2 == 0 else map_width - 1
		for col in range(row_width):
			var hex = HEX_TILE.instantiate()
			var axial = offset_to_axial(col, row)
			hex.coordinates = axial
			hex.position = axial_to_pixel(axial, hex.radius)
			
			if (col == 4 and row == 4) or (col == 3 and ((row == 3)or(row == 4)or(row == 5))):
				hex.set_tile_data(CASTLE_DATA)
			elif (col == 5 and row == 1) or (col == 6 and row == 2):
				hex.set_tile_data(FOREST_DATA)
			elif (col == 1 and row == 6) or (col == 1 and row == 7):
				hex.set_tile_data(SWAMP_DATA)
			elif (col == 1 and row == 4):
				hex.set_tile_data(STONE_DATA)
			elif (col == 6 and row == 6) or (col == 5 and row == 7):
				hex.set_tile_data(MOUNTAIN_DATA)
			elif (col == 1 and row == 1) or (col == 1 and row == 2):
				hex.set_tile_data(SETTLEMENT_DATA)
			elif (col == 6 and row == 4):
				hex.set_tile_data(RUINS_DATA)
			else:
				hex.set_tile_data(GRASS_DATA)
			
			#var roll = randi_range(1,100)
			#if roll <= 40:
				#hex.set_tile_type(HexTile.TileType.GRASS)
			#elif roll <= 65:
				#hex.set_tile_type(HexTile.TileType.FOREST)
			#elif roll <= 70:
				#hex.set_tile_type(HexTile.TileType.SWAMP)
			#elif roll <= 75:
				#hex.set_tile_type(HexTile.TileType.STONE)
			#elif roll <= 80:
				#hex.set_tile_type(HexTile.TileType.MOUNTAIN)
			#elif roll <= 90:
				#hex.set_tile_type(HexTile.TileType.SETTLEMENT)
			#elif roll <= 95:
				#hex.set_tile_type(HexTile.TileType.SETTLEMENT)
			#else:
				#hex.set_tile_type(HexTile.TileType.CASTLE)
			
			add_child(hex)
			hex_tiles[axial] = hex
			hex.tile_clicked.connect(_on_tile_clicked)

# moves the camera to middle of the hex map
func center_map():
	# takes from hex map container and find mid point
	var min_pos = Vector2(INF, INF)
	var max_pos = Vector2(-INF, -INF)
	for hex in hex_tiles.values():
		min_pos = min_pos.min(hex.position)
		max_pos = max_pos.max(hex.position)

	# move cam to mid point
	var camera = Camera2D.new()
	camera.position = (min_pos + max_pos) / 2.0
	add_child(camera)

# find logical coord of nearby tiles
func get_neighbors(coordinates: Vector2i) -> Array[Vector2i]:
	var directions = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
		Vector2i(1, -1),
		Vector2i(-1, 1)
	]
	var neighbors: Array[Vector2i] = []
	
	for direction in directions:
		neighbors.append(coordinates + direction)
		
	return neighbors

func get_occupied_coordinates() -> Array[Vector2i]:
	var occupied: Array[Vector2i] = [player_coordinates]
	
	for actor in turn_manager.all_actors:
		if not is_instance_valid(actor):
			continue
		
		if actor.has_method("get") and actor.get("coordinates") != null:
			var actor_coordinates: Vector2i = actor.coordinates
		
			if not occupied.has(actor_coordinates):
				occupied.append(actor_coordinates)
	return occupied

func get_random_type(required_tile_data) -> Vector2i:
	var candidates: Array[Vector2i] = []
	var occupied = get_occupied_coordinates()
	
	for coordinates in hex_tiles:
		var tile = hex_tiles[coordinates]
	
		if occupied.has(coordinates):
			continue
			
		if tile.tile_data != required_tile_data:
			continue
		
		candidates.append(coordinates)
		
	if candidates.is_empty():
		push_warning("No available tiles of the requested type!")
		return Vector2i(999999, 999999)
	
	return candidates.pick_random()

func get_random_tile() -> Vector2i:
	var candidates: Array[Vector2i] = []
	var occupied = get_occupied_coordinates()
	
	for coordinates in hex_tiles:
		var tile = hex_tiles[coordinates]
	
		if occupied.has(coordinates):
			continue
		
		if tile.tile_data == CASTLE_DATA:
			continue
		
		candidates.append(coordinates)
	
	if candidates.is_empty():
		push_warning("No valid non-Castle tiles!")
		return Vector2i(999999, 999999)

	return candidates.pick_random()


func create_player(): 
	player = PLAYER.instantiate()
	player.character_data = DEFAULT_HERO
	player.coordinates = player_coordinates
	
	add_child(player)
	player.position = hex_tiles[player_coordinates].position
	
	turn_manager.register_actor(player)

#func spawn_bane() -> void:
	#bane = NPC.instantiate()
	#bane.character_data = BANE_DATA
	#bane.active_phase = "Night"
	#bane.npc_color = Color(0.478, 0.152, 0.595, 1.0)
#
	## Temporary spawn location, using the same
	## offset coordinates as map generation.
	#var spawn_coordinates = offset_to_axial(4, 3)
#
	#if not hex_tiles.has(spawn_coordinates):
		#push_warning("Bane spawn tile does not exist!")
		#bane.free()
		#return
#
	#add_child(bane)
	#bane.position = hex_tiles[spawn_coordinates].position
	#
	#turn_manager.register_actor(bane)


func spawn_bane(spawn_coordinates: Vector2i) -> void:
	var new_bane = NPC.instantiate()
	new_bane.character_data = BANE_DATA
	new_bane.active_phase = "Night"
	new_bane.npc_color = Color(0.478, 0.152, 0.595, 1.0)
	
	add_child(new_bane)
	new_bane.position = hex_tiles[spawn_coordinates].position
	
	turn_manager.register_actor(new_bane)


func spawn_guard(spawn_coordinates: Vector2i) -> void:
	var new_guard = NPC.instantiate()
	new_guard.character_data = GUARD_DATA
	new_guard.active_phase = "Day"
	new_guard.npc_color = Color(0.864, 0.71, 0.0, 1.0)
	new_guard.coordinates = spawn_coordinates
	
	add_child(new_guard)
	new_guard.position = hex_tiles[spawn_coordinates].position
	
	turn_manager.register_actor(new_guard)


func move_player(new_coordinates):
	var tile = hex_tiles[new_coordinates]
	var movement_cost = tile.tile_data.movement_cost
	
	if not player.spend_ap(movement_cost):
		return
		
	player_coordinates = new_coordinates
	player.coordinates = new_coordinates
	player.position = hex_tiles[new_coordinates].position
		
	print("Moved onto new Tile")
	print("Type: ",tile.tile_data.display_name)
	print("Movement Cost: ",tile.tile_data.movement_cost)
	print("Health Change: ",tile.tile_data.health_change)
	print("Coordinates: ",new_coordinates)
	
	player.change_health(tile.tile_data.health_change)

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
	elif actor == bane:
		print("=== Bane's Turn ===")
		print("Bane cant do shit so pass")
	elif actor == guard:
		print("=== Guard's Turn ===")
		print("Guard cant do shit so pass")
	
	update_turn_order_ui()


# check if tile can move
func _on_tile_clicked(clicked_coordinates):
	if turn_manager.current_actor != player:
		print("not ur turn yet bitch")
		return
	
	var neighbors = get_neighbors(player_coordinates)
	
	if clicked_coordinates in neighbors:
		move_player(clicked_coordinates)

func _on_end_turn_button_pressed() -> void:
	turn_manager.end_turn()

func _on_phase_changed(night: bool) -> void:
	$CanvasLayer/NightOverlay.visible = night
	
	if night:
		print("Night has fallen!")
		
		var ruin_spawn = get_random_type(RUINS_DATA)
		spawn_bane(ruin_spawn)
	else:
		print("Day has begun!")
	
	update_turn_order_ui()
