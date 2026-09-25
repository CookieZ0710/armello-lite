extends Node2D

const PLAYER = preload("res://scenes/Player.tscn")
const HEX_TILE = preload("res://scenes/HexTile.tscn")

@export var map_width: int = 24
@export var map_height: int = 5

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
	return Vector2i(col, row - (col >> 1))

# logical coord into visual coord
func axial_to_pixel(axial: Vector2i, radius: float) -> Vector2:
	return Vector2(
		radius * 1.5 * axial.x,
		radius * sqrt(3) * (axial.y + axial.x / 2.0)
	)

# makes the hex tiles based on the map size
func generate_map():
	for col in range(map_width):
		for row in range(map_height):
			var hex = HEX_TILE.instantiate()
			var axial = offset_to_axial(col, row)
			hex.coordinates = axial
			hex.position = axial_to_pixel(axial, hex.radius)
			
			var roll = randi_range(1,100)
			if roll <= 40:
				hex.set_tile_type(HexTile.TileType.GRASS)
			elif roll <= 65:
				hex.set_tile_type(HexTile.TileType.FOREST)
			elif roll <= 70:
				hex.set_tile_type(HexTile.TileType.SWAMP)
			elif roll <= 75:
				hex.set_tile_type(HexTile.TileType.STONE)
			elif roll <= 80:
				hex.set_tile_type(HexTile.TileType.MOUNTAIN)
			elif roll <= 90:
				hex.set_tile_type(HexTile.TileType.SETTLEMENT)
			elif roll <= 95:
				hex.set_tile_type(HexTile.TileType.SETTLEMENT)
			else:
				hex.set_tile_type(HexTile.TileType.CASTLE)
			
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
	print("Type: ",tile.get_tile_type_name())
	print("Movement Cost: ",tile.movement_cost)
	print("Health Change: ",tile.health_change)


# check if tile can move
func _on_tile_clicked(clicked_coordinates):
	var neighbors = get_neighbors(player_coordinates)
	
	if clicked_coordinates in neighbors:
		move_player(clicked_coordinates)
