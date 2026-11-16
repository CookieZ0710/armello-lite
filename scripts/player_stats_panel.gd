extends PanelContainer

var player: Node = null

@onready var body_label: Label = $MainLayout/CharacterInfo/Stats/BodyLabel
@onready var fight_label: Label = $MainLayout/CharacterInfo/Stats/FightLabel
@onready var wits_label: Label = $MainLayout/CharacterInfo/Stats/WitsLabel
@onready var spirit_label: Label = $MainLayout/CharacterInfo/Stats/SpiritLabel
@onready var rot_label: Label = $MainLayout/CharacterInfo/Stats/RotLabel
@onready var health_bar: ProgressBar = $MainLayout/HealthBar

@export var healthy_color: Color = Color(0.25, 0.8, 0.2)
@export var low_health_color: Color = Color(0.85, 0.15, 0.15)

var health_fill_style: StyleBoxFlat

func _ready() -> void:
	health_fill_style = StyleBoxFlat.new()
	health_fill_style.bg_color = healthy_color
	health_fill_style.corner_radius_top_left = 4
	health_fill_style.corner_radius_top_right = 4
	health_fill_style.corner_radius_bottom_left = 4
	health_fill_style.corner_radius_bottom_right = 4
	
	health_bar.add_theme_stylebox_override(
		"fill",
		health_fill_style
	)

func update_stats() -> void:
	if not is_instance_valid(player):
		return
		
	if player.character_data == null:
		return
	
	var data = player.character_data
	
	body_label.text = "Body: %d / %d" % [
		player.current_health,
		player.max_health
	]
	
	fight_label.text = "Fight: %d" % data.fight
	wits_label.text = "Wits: %d" % data.wits
	spirit_label.text = "Spirit: %d" % data.spirit
	
	var health_percentage = 0.0
	
	if player.max_health > 0:
		health_percentage = float(player.current_health) / player.max_health
		
	if health_percentage < 0.25:
		health_fill_style.bg_color = low_health_color
	else: 
		health_fill_style.bg_color = healthy_color
	
	health_bar.max_value = player.max_health
	health_bar.value = player.current_health
