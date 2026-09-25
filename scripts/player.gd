extends Area2D

var coordinates = Vector2i.ZERO
@export var radius: float = 20.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var points = PackedVector2Array()
	
	for i in range(20):
		var angle = deg_to_rad(i * 360.0 / 20.0)
		
		points.append(Vector2(cos(angle), sin (angle)) * radius)
	
	$Polygon2D.polygon = points
