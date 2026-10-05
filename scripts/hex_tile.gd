class_name HexTile
extends Area2D

signal tile_clicked(coordinates)
var coordinates = Vector2i.ZERO

@export var radius: float = 40.0
@export var tile_data: HexTileData

func _ready():
	var points = PackedVector2Array()
	
	for i in range(6):
		var angle = deg_to_rad(60 * i)
		var point = Vector2(
			cos(angle),
			sin(angle)
		)* radius
		
		points.append(point)
		
	$Polygon2D.polygon = points
	$CollisionPolygon2D.polygon = points
	
	var border_points = points.duplicate()
	border_points.append(points[0])
	
	$Line2D.points = border_points
	$Line2D.width = 2.0


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			tile_clicked.emit(coordinates)


func apply_tile_data() -> void:
	if tile_data == null:
		return
		
	$Polygon2D.color = tile_data.tile_color
	
func set_tile_data(data: HexTileData) -> void:
	tile_data = data
	apply_tile_data()
