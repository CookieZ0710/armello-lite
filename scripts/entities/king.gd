extends Node2D

@export var character_data: CharacterData
@export var radius: float = 40.0
@export var king_color: Color = Color(Color(0.149, 0.349, 1.0))
@export var outline_color: Color = Color(0.9, 0.7, 0.15)

var fight: int
var max_body: int
var current_body: int
var rot: int

func _ready() -> void:
	initialise_character()
	create_visual()
	
func initialise_character() -> void:
	if character_data == null:
		push_warning("No character stuff bruh")
		return
	
	fight = character_data.fight
	max_body = character_data.body
	current_body = max_body
	rot = character_data.rot
	
	print("=== King Initialised ===")
	print("Name: ", character_data.character_name)
	print("Fight: ", fight)
	print("Body: ", current_body, "/", max_body)
	print("Rot: ", rot)
	
	
func create_visual() -> void:
	z_index = 10
	
	var points = PackedVector2Array()
	
	for i in range(6):
		var angle = deg_to_rad(60 * i + 30)
		var point = Vector2(
			cos(angle),
			sin(angle)
		) * radius
		
		points.append(point)
	
	$VirtualHex.polygon = points
	$VirtualHex.color = king_color
	
	var border_points = points.duplicate()
	border_points.append(points[0])
	
	$HexOutline.points = border_points
	$HexOutline.width = 3.0
	$HexOutline.default_color = outline_color
	
	var crown_points = PackedVector2Array([
		Vector2(-16, -7),
		Vector2(-16, 5),
		Vector2(16, 5),
		Vector2(16, -7),
		Vector2(7, 0),
		Vector2(0, -15),
		Vector2(-7, 0)
	])
	
	$Crown.polygon = crown_points
	$Crown.color = outline_color
	
	
func on_day_started() -> void:
	current_body = maxi(0, current_body-1)
	
	print("=== King: Day Effect ===")
	print("King loses 1 Body.")
	print("Body: ", current_body, "/", max_body)
	
	
func on_night_started() -> void:
	rot += 1
	
	print("=== King: Night Effect ===")
	print("King gains 1 Rot.")
	print("Rot: ", rot)
