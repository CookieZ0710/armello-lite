extends Control

signal return_requested
signal roll_requested

enum DiceFace {
	SWORD,
	SHIELD,
	SUN,
	MOON,
	ROT,
	WILD
}

@export_group("Dice Icons")
@export var sword_icon: Texture2D
@export var shield_icon: Texture2D
@export var sun_icon: Texture2D
@export var moon_icon: Texture2D
@export var rot_icon: Texture2D
@export var wild_icon: Texture2D


#TOP SECTION
@onready var attacker_name: Label = $Background/MainLayout/TopSection/AttackerInfo/AttackerName
@onready var defender_name : Label = $Background/MainLayout/TopSection/DefenderInfo/DefenderName

@onready var attacker_health: ProgressBar = $Background/MainLayout/TopSection/AttackerInfo/AttackerHealthbar
@onready var defender_health: ProgressBar = $Background/MainLayout/TopSection/DefenderInfo/DefenderHealthbar

@onready var phase_icon: TextureRect = $Background/MainLayout/TopSection/PhaseIndicator/PhaseIcon


#PORTRAITS
@onready var attacker_portrait : TextureRect = $Background/MainLayout/PortraitSection/AttackerPortrait
@onready var defender_portrait : TextureRect = $Background/MainLayout/PortraitSection/DefenderPortrait

#BOTTOM
#ATK STATS
@onready var attacker_body : Label = $Background/MainLayout/BottomSection/AttackerStats/AttackerBody
@onready var attacker_fight : Label = $Background/MainLayout/BottomSection/AttackerStats/AttackerFight
@onready var attacker_wits : Label = $Background/MainLayout/BottomSection/AttackerStats/AttackerWits
@onready var attacker_spirit : Label = $Background/MainLayout/BottomSection/AttackerStats/AttackerSpirit
@onready var attacker_rot : Label = $Background/MainLayout/BottomSection/AttackerStats/AttackerRot
@onready var attacker_bonus_dice : Label = $Background/MainLayout/BottomSection/AttackerStats/AttackerBonusDice
@onready var attacker_bonus_def : Label = $Background/MainLayout/BottomSection/AttackerStats/AttackerBonusDef

#DFN STATS
@onready var defender_body : Label = $Background/MainLayout/BottomSection/DefenderStats/DefenderBody
@onready var defender_fight : Label = $Background/MainLayout/BottomSection/DefenderStats/DefenderFight
@onready var defender_wits : Label = $Background/MainLayout/BottomSection/DefenderStats/DefenderWits
@onready var defender_spirit : Label = $Background/MainLayout/BottomSection/DefenderStats/DefenderSpirit
@onready var defender_rot : Label = $Background/MainLayout/BottomSection/DefenderStats/DefenderRot
@onready var defender_bonus_dice : Label = $Background/MainLayout/BottomSection/DefenderStats/DefenderBonusDice
@onready var defender_bonus_def : Label = $Background/MainLayout/BottomSection/DefenderStats/DefenderBonusDef

#DICE
@onready var attacker_dice_grid: GridContainer = $Background/MainLayout/BottomSection/AttackerDice
@onready var defender_dice_grid: GridContainer = $Background/MainLayout/BottomSection/DefenderDice

@onready var roll_button: Button = $Background/MainLayout/BottomSection/RollButton
@onready var return_button: Button = $ReturnButton

var attacker_dice_slots: Array[TextureRect] = []
var defender_dice_slots: Array[TextureRect] = []


func _ready() -> void:
	roll_button.pressed.connect(_on_roll_pressed)
	return_button.pressed.connect(func(): return_requested.emit())
	

func show_encounter(context: CombatContext, is_night: bool) -> void:
	#NAME
	attacker_name.text = get_character_name(context.attacker)
	defender_name.text = get_character_name(context.defender)

	#HEALTH
	attacker_health.max_value = context.attacker_body
	attacker_health.value = context.attacker_current_health
	
	defender_health.max_value = context.defender_body
	defender_health.value = context.defender_current_health
	
	#PORTRAITS
	attacker_portrait.texture = context.attacker.character_data.portrait
	defender_portrait.texture = context.defender.character_data.portrait
	
	#STATS
	attacker_body.text = "Body: %d" % context.attacker_body
	attacker_fight.text = "Fight: %d" % context.attacker_fight
	attacker_wits.text = "Wits: %d" % context.attacker.character_data.wits
	attacker_spirit.text = "Spirit: %d" % context.attacker.character_data.spirit
	attacker_rot.text = "Rot: %d" % context.attacker_rot
	attacker_bonus_dice.text = "Bonus Dice: +%d" % context.attacker_bonus_dice
	attacker_bonus_def.text = "Defence: +0"

	defender_body.text = "Body: %d" % context.defender_body
	defender_fight.text = "Fight: %d" % context.defender_fight
	defender_wits.text = "Wits: %d" % context.defender.character_data.wits
	defender_spirit.text = "Spirit: %d" % context.defender.character_data.spirit
	defender_rot.text = "Rot: %d" % context.defender_rot
	defender_bonus_dice.text = "Bonus Dice: +%d" % context.defender_bonus_dice
	defender_bonus_def.text = "Defence: +%d" % context.defender_terrain_bonus
	
	clear_dice_slots()
	
	create_dice_slots(attacker_dice_grid, context.attacker_total_dice, attacker_dice_slots)
	create_dice_slots(defender_dice_grid, context.defender_total_dice, defender_dice_slots)
	
	roll_button.disabled = false
	show()


func get_character_name(character: Node) -> String:
	if character.character_data != null:
		return character.character_data.character_name
	
	return character.name
	
		
func clear_dice_slots() -> void:
	for slot in attacker_dice_slots:
		slot.queue_free()
	
	for slot in defender_dice_slots:
		slot.queue_free()
	
	attacker_dice_slots.clear()
	defender_dice_slots.clear()
	
func create_dice_slots(grid: GridContainer, amount: int, storage: Array[TextureRect]) -> void:
	for i in range(amount):
		var slot = TextureRect.new()
		
		slot.custom_minimum_size = Vector2(48, 48)
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		grid.add_child(slot)
		storage.append(slot)


func get_face_texture(face: int) -> Texture2D:
	match face:
		DiceFace.SWORD:
			return sword_icon
		DiceFace.SHIELD:
			return shield_icon
		DiceFace.SUN:
			return sun_icon
		DiceFace.MOON:
			return moon_icon
		DiceFace.ROT:
			return rot_icon
		DiceFace.WILD:
			return wild_icon
	
	return null


func animate_roll(
	attacker_result: Array[int], 
	defender_result: Array[int]
) -> void:
	var all_slots = attacker_dice_slots + defender_dice_slots
	
	for round in range(15):
		for slot in all_slots:
			slot.texture = get_face_texture(randi_range(0,5))
		
		await get_tree().create_timer(0.07).timeout
	
	for i in range(attacker_result.size()):
		attacker_dice_slots[i].text = attacker_result[i]
	
	for i in range(defender_result.size()):
		defender_dice_slots[i].text = defender_result[i]


func _on_roll_pressed() -> void:
	if roll_button.disabled:
		return
	
	roll_button.disabled = true
	roll_requested.emit()
