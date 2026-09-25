class_name HexTile
extends Area2D

signal tile_clicked(coordinates)
var coordinates = Vector2i.ZERO
enum TileType {
	GRASS,
	SWAMP,
	MOUNTAIN
}
var tile_type: TileType = TileType.GRASS	# our default tile type
var movement_cost: int = 1
var health_change: int = 0

@export var radius: float = 40.0
@export var tile_color: Color = Color(0.25, 0.55, 0.35)

func _ready():
	var polygon = $Polygon2D
	var points = PackedVector2Array()
	
	for i in range(6):
		var angle = deg_to_rad(60 * i)
		var point = Vector2(
			cos(angle),
			sin(angle)
		)* radius
		
		points.append(point)
		
	$Polygon2D.polygon = points
	$Polygon2D.color = tile_color
	$CollisionPolygon2D.polygon = points
	
	var border_points = points.duplicate()
	border_points.append(points[0])
	
	$Line2D.points = border_points
	$Line2D.width = 2.0


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			tile_clicked.emit(coordinates)

func set_tile_type(type: TileType):
	tile_type = type
	
	match tile_type:
		TileType.GRASS:
			tile_color = Color(0.25, 0.55, 0.35)
			movement_cost = 1
			health_change = 0
		TileType.SWAMP:
			tile_color = Color(0.45, 0.30, 0.20)
			movement_cost = 1
			health_change = -1
		TileType.MOUNTAIN:
			tile_color = Color(0.8, 0.8, 0.8)
			movement_cost = 2
			health_change = 0
			
	$Polygon2D.color = tile_color


func get_tile_type_name() -> String:	# temporary can remove
	match tile_type:
		TileType.GRASS:
			return "GRASS"
		TileType.SWAMP:
			return "SWAMP"
		TileType.MOUNTAIN:
			return "MOUNTAIN"
	
	return "UNKNOWN"
