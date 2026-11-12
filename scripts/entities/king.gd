extends Node2D

@export var character_data: CharacterData
@export var radius: float = 24.0
@export var king_color: Color = Color(0.9, 0.7, 0.15)

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
	
	for i in range(24):
		var angle = deg_to_rad(i * 360.0 / 24.0)
		points.append(
			Vector2(cos(angle), sin(angle)) * radius
		)
	
	$Polygon2D.polygon = points
	$Polygon2D.color = king_color
	
	
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
