extends Area2D

@export var character_data: CharacterData
@export var radius: float = 20.0

var current_health: int
var max_health: int
var fight: int

func _ready() -> void:
	var points = PackedVector2Array()
	
	for i in range(20):
		var angle = deg_to_rad(i * 360.0 / 20.0)
		points.append(Vector2(cos(angle), sin (angle)) * radius)
		
	$Polygon2D.polygon = points
	$Polygon2D.color = Color(0.7, 0.2, 0.25)
	
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
