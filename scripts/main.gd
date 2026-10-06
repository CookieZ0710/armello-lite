extends Node2D

const PLAYER = preload("res://scenes/Player.tscn")
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

func _ready() -> void:
	randomize()
	
	generate_map()		# make hex tiles
	center_map()		# check and move to mid of tiles
	
	player_coordinates = offset_to_axial(2, 2)
	create_player()		# add player

# take normal coord into logical use
func offset_to_axial(col: int, row: int) -> Vector2i:
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


func create_player(): 
	player = PLAYER.instantiate()
	player.coordinates = player_coordinates
	add_child(player)
	player.position = hex_tiles[player_coordinates].position


func move_player(new_coordinates):
	player_coordinates = new_coordinates
	player.coordinates = new_coordinates
	player.position = hex_tiles[new_coordinates].position
	
	var tile = hex_tiles[new_coordinates]
	print("Moved onto new Tile")
	print("ID: ",tile.tile_data.id)
	print("Type: ",tile.tile_data.display_name)
	print("Movement Cost: ",tile.tile_data.movement_cost)
	print("Health Change: ",tile.tile_data.health_change)
	print("Coordinates: ",new_coordinates)


# check if tile can move
func _on_tile_clicked(clicked_coordinates):
	var neighbors = get_neighbors(player_coordinates)
	
	if clicked_coordinates in neighbors:
		move_player(clicked_coordinates)
