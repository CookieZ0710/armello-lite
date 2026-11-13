extends PanelContainer

var player: Node = null

@onready var body_label: Label = $MainLayout/CharacterInfo/Stats/BodyLabel
@onready var fight_label: Label = $MainLayout/CharacterInfo/Stats/FightLabel
@onready var wits_label: Label = $MainLayout/CharacterInfo/Stats/WitsLabel
@onready var spirit_label: Label = $MainLayout/CharacterInfo/Stats/SpiritLabel
@onready var rot_label: Label = $MainLayout/CharacterInfo/Stats/RotLabel

@onready var health_bar: ProgressBar = $MainLayout/HealthBar

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
	
	health_bar.max_value = player.max_health
	health_bar.value = player.current_health
