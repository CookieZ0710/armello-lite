extends Area2D

var coordinates = Vector2i.ZERO
@export var radius: float = 20.0

@export var character_data: CharacterData
#Runtime stats
var current_health: int 
var max_health: int
var current_ap: int

var gold: int = 0
var mana: int = 0
var rot: int = 0
var prestige: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var points = PackedVector2Array()
	
	for i in range(20):
		var angle = deg_to_rad(i * 360.0 / 20.0)
		
		points.append(Vector2(cos(angle), sin (angle)) * radius)
	
	$Polygon2D.polygon = points
	initialise_character()
	

func initialise_character() -> void:
	if character_data == null:
		push_warning("No char data dumbo")
		return
		
	max_health = character_data.body
	current_health = max_health
	current_ap = 30
	
	print("=== Character Initialised ===")
	print("Name: ", character_data.character_name)
	print("Fight: ", character_data.fight)
	print("Body: ", character_data.body)
	print("Wits: ", character_data.wits)
	print("Spirit: ", character_data.spirit)
	print("Health: ", current_health, "/", max_health)
	print("AP: ", current_ap)

func change_health(amount: int) -> void:
	var previous_health = current_health
	
	current_health = clampi(current_health + amount,0,max_health)
	
	print(
		"Health: ", previous_health," -> ", current_health,
		" (", amount," from tile)"
	)

func spend_ap(amount: int) -> bool:
	if current_ap < amount:
		print("Not enough AP!")
		return false
		
	current_ap -= amount
	print("AP remaining: ", current_ap)
	return true
		
