class_name HexTileData
extends Resource

@export_group("Identity")
@export var id: String
@export var display_name: String = ""

@export_group("Movement")
@export var movement_cost: int = 1


@export_group("Effects")
@export var health_change: int = 0
@export var defence_bonus: int = 0
@export var night_stealth: bool = false

@export_group("Visuals")
@export var tile_color: Color = Color.WHITE
