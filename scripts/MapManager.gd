extends Node

signal tile_clicked(coordinates: Vector2i)

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

var hex_tiles: Dictionary = {}

var player: Node = null
var turn_manager: Node = null


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

func get_occupied_coordinates(exclude_actor: Node = null) -> Array[Vector2i]:
	var occupied: Array[Vector2i] = []
	
	if is_instance_valid(player) and player != exclude_actor:
		occupied.append(player.coordinates)
		
	if is_instance_valid(turn_manager):
		for actor in turn_manager.all_actors:
			if not is_instance_valid(actor):
				continue
			
			if actor == player or actor == exclude_actor:
				continue
			
			if actor.coordinates not in occupied:
				occupied.append(actor.coordinates)

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

func get_path_to_nearest_tile_type(start: Vector2i, required_tile_data, exclude_actor: Node = null) -> Array[Vector2i]:
	
	if not hex_tiles.has(start):
		push_warning("Pathfinding started from an invalid coordinate: ", start)
		return []
	
	var queue: Array[Vector2i] = [start]
	var visited: Dictionary = {start: true}
	var came_from: Dictionary = {}
	
	var occupied = get_occupied_coordinates(exclude_actor)
	
	while not queue.is_empty():
		var current = queue.pop_front()
		if not hex_tiles.has(current):
			continue
			
		var current_tile = hex_tiles[current]
		
		if current_tile.tile_data == required_tile_data and current != start:
			var path: Array[Vector2i] = [current]
			var step = current
			
			while step != start:
				step = came_from[step]
				path.append(step)
			
			path.reverse()
			return path
		
		for neighbor in get_neighbors(current):
			if not hex_tiles.has(neighbor):
				continue
			
			if visited.has(neighbor):
				continue
				
			if neighbor in occupied:
				continue
			
			var neighbor_tile = hex_tiles[neighbor]
			if neighbor_tile.tile_data == CASTLE_DATA:
				continue
			
			visited[neighbor] = true
			came_from[neighbor] = current
			queue.append(neighbor)
		
	return []
	

func _on_tile_clicked(coordinates: Vector2i) -> void:
	tile_clicked.emit(coordinates)
