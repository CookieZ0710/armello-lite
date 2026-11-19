extends Control

signal return_requested
signal roll_requested

const DICE_FACES: Array[String] = [
	"⚔", "🛡", "☀", "☾", "☠", "★"
]

const BACKGROUND_COLOR = Color(0.52, 0.52, 0.52)
const PANEL_COLOR = Color(0.22, 0.22, 0.22)
const DICE_COLOR = Color(0.94, 0.94, 0.94)

var attacker_dice_slots: Array[Label] = []
var defender_dice_slots: Array[Label] = []
var attacker_dice_grid: GridContainer
var defender_dice_grid: GridContainer

var roll_button: Button
var attacker_name_label: Label
var defender_name_label: Label
var attacker_health_bar: ProgressBar
var defender_health_bar: ProgressBar
var attacker_health_label: Label
var defender_health_label: Label
var attacker_stats_label: Label
var defender_stats_label: Label
var phase_label: Label
var attacker_portrait: TextureRect
var defender_portrait: TextureRect


func _ready() -> void:
	build_screen()
	
func build_screen() -> void:
	var background = ColorRect.new()
	background.color = BACKGROUND_COLOR
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(background)
	
	var layout = VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override("separation", 12)
	background.add_child(layout)
	
	build_top_section(layout)
	build_portrait_section(layout)
	build_bottom_section(layout)
	
func build_top_section(parent: VBoxContainer) -> void:
	var top = HBoxContainer.new()
	top.custom_maximum_size.y = 145
	top.add_theme_constant_override("separation", 16)
	parent.add_child(top)
	
	var attacker_info = VBoxContainer.new()
	attacker_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(attacker_info)
	
	attacker_name_label = create_label("Attacker", 28, HORIZONTAL_ALIGNMENT_LEFT)
	attacker_info.add_child(attacker_name_label)
	
	attacker_health_bar = ProgressBar.new()
	attacker_health_bar.custom_minimum_size.y = 38
	attacker_health_bar.show_percentage = false
	attacker_info.add_child(attacker_health_bar)
	configure_health_bar(attacker_health_bar)
	
	attacker_health_label = create_label("", 22, HORIZONTAL_ALIGNMENT_CENTER)
	attacker_info.add_child(attacker_health_label)
	
	var phase_container = CenterContainer.new()
	phase_container.custom_minimum_size.x = 90
	top.add_child(phase_container)
	
	phase_label = create_label("☀", 42)
	phase_container.add_child(phase_label)
	
	var defender_info = VBoxContainer.new()
	defender_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(defender_info)
	
	defender_name_label = create_label("Defender", 28, HORIZONTAL_ALIGNMENT_RIGHT)
	defender_info.add_child(defender_name_label)
	
	defender_health_bar = ProgressBar.new()
	defender_health_bar.custom_minimum_size.y = 38
	defender_health_bar.show_percentage = false
	defender_info.add_child(defender_health_bar)
	configure_health_bar(defender_health_bar)
	
	defender_health_label = create_label("", 22, HORIZONTAL_ALIGNMENT_CENTER)
	defender_info.add_child(defender_health_label)
	
		
func build_portrait_section(parent: VBoxContainer) -> void:
	var portraits = HBoxContainer.new()
	portraits.size_flags_vertical = Control.SIZE_EXPAND_FILL
	portraits.add_theme_constant_override("separation", 20)
	parent.add_child(portraits)
	
	attacker_portrait = TextureRect.new()
	attacker_portrait.custom_minimum_size = Vector2(210, 210)
	attacker_portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	attacker_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	attacker_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	attacker_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portraits.add_child(attacker_portrait)
	
	var centre_space = Control.new()
	centre_space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	portraits.add_child(centre_space)
	
	defender_portrait = TextureRect.new()
	defender_portrait.custom_minimum_size = Vector2(210, 210)
	defender_portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	defender_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	defender_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	defender_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	defender_portrait.size_flags_stretch_ratio = 1.0
	portraits.add_child(defender_portrait)
	
func build_bottom_section(parent: VBoxContainer) -> void:
	var bottom = HBoxContainer.new()
	bottom.custom_minimum_size.y = 245
	bottom.add_theme_constant_override("separation", 8)
	parent.add_child(bottom)
	
	#attacker_stats_label = create_label("", 20)
	#attacker_stats_label.custom_minimum_size.x = 115
	#attacker_stats_label.add_theme_stylebox_override("normal", make_panel_style())
	#bottom.add_child(attacker_stats_label)
	
	attacker_stats_label = create_stats_panel(
		bottom, HORIZONTAL_ALIGNMENT_LEFT
	)
	
	var attacker_dice_container = create_dice_container()
	attacker_dice_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(attacker_dice_container)
	attacker_dice_grid = attacker_dice_container
	
	var roll_container = CenterContainer.new()
	roll_container.custom_minimum_size.x = 115
	bottom.add_child(roll_container)
	
	roll_button = Button.new()
	roll_button.text = "ROLL"
	roll_button.custom_minimum_size = Vector2(105, 105)
	roll_button.add_theme_font_size_override("font_size", 24)
	roll_button.pressed.connect(_on_roll_pressed)
	roll_container.add_child(roll_button)
	
	var defender_dice_container = create_dice_container()
	defender_dice_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(defender_dice_container)
	defender_dice_grid = defender_dice_container
	
	#defender_stats_label = create_label("", 20)
	#defender_stats_label.custom_minimum_size.x = 115
	#defender_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	#defender_stats_label.add_theme_stylebox_override("normal", make_panel_style())
	#bottom.add_child(defender_stats_label)
	
	defender_stats_label = create_stats_panel(
		bottom, HORIZONTAL_ALIGNMENT_RIGHT
	)
	
	var return_button = Button.new()
	return_button.text = "Return to Map"
	return_button.position = Vector2(15, 15)
	return_button.pressed.connect(func(): return_requested.emit())
	add_child(return_button)
	

func create_dice_container() -> GridContainer:
	var grid = GridContainer.new()
	grid.columns = 5
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 5)
	grid.add_theme_constant_override("v_separation", 5)
	return grid


func create_label(
	text_value: String,
	font_size: int,
	alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> Label:
	var label = Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.BLACK)
	return label
	

func create_stats_panel(
	parent: HBoxContainer,
	alignment: HorizontalAlignment
) -> Label:
	var panel = PanelContainer.new()
	panel.custom_minimum_size.x = 115
	panel.add_theme_stylebox_override("panel", make_panel_style())
	parent.add_child(panel)

	var label = create_label("", 18, alignment)
	label.add_theme_color_override("font_color", Color.WHITE)
	panel.add_child(label)
	
	return label

func make_panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.bg_color = PANEL_COLOR
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func show_encounter(context: CombatContext, is_night: bool) -> void:
	attacker_name_label.text = get_character_name(context.attacker)
	defender_name_label.text = get_character_name(context.defender)

	update_health(
		attacker_health_bar,
		attacker_health_label,
		context.attacker_current_health,
		context.attacker_body
	)
	
	update_health(
		defender_health_bar,
		defender_health_label,
		context.defender_current_health,
		context.defender_body
	)
	
	phase_label.text = "☾" if is_night else "☀"
	
	attacker_portrait.texture = context.attacker.character_data.portrait
	defender_portrait.texture = context.defender.character_data.portrait
	
	attacker_stats_label.text = get_stats_text(
		context.attacker,
		context.attacker_fight,
		context.attacker_rot,
		context.attacker_bonus_dice,
		0
	)

	defender_stats_label.text = get_stats_text(
		context.defender,
		context.defender_fight,
		context.defender_rot,
		context.defender_bonus_dice,
		context.defender_terrain_bonus
	)
	
	#create_dice_slots(
		#context.attacker_total_dice,
		#attacker_dice_slots,
		#get_node("Background") if has_node("Background") else null
	#)
	
	clear_dice_slots()
	
	#var bottom = get_child(0).get_child(0).get_child(2)
	#var attacker_grid = bottom.get_child(1)
	#var defender_grid = bottom.get_child(3)
	
	create_dice_slots_in_grid(
		attacker_dice_grid,
		context.attacker_total_dice,
		attacker_dice_slots
	)

	create_dice_slots_in_grid(
		defender_dice_grid,
		context.defender_total_dice,
		defender_dice_slots
	)
	
	roll_button.disabled = false
	show()


func get_character_name(character: Node) -> String:
	if character.character_data != null:
		return character.character_data.character_name
	
	return character.name


func update_health(
	bar: ProgressBar,
	label: Label,
	current: int,
	maximum: int
) -> void:
	bar.max_value = maximum
	bar.value = current
	label.text ="%d / %d" % [current, maximum]
	

func get_stats_text(
	character: Node,
	fight: int,
	rot: int,
	bonus_dice: int,
	terrain_bonus: int
) -> String:
	var body = character.character_data.body
	var wits = character.character_data.wits
	var spirit = character.character_data.spirit
	
	return(
		"♥  %d\n⚔  %d\nW  %d\nS  %d\n☠  %d\n\nBonus: +%d\nDefence: +%d"
		% [
			body,
			fight,
			wits,
			spirit,
			rot,
			bonus_dice,
			terrain_bonus
		]
	)


func create_dice_slots_in_grid(
	grid: GridContainer,
	amount: int,
	storage: Array[Label]
) -> void:
	for i in range(amount):
		var slot = PanelContainer.new()
		slot.custom_minimum_size = Vector2(48, 48)
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.23, 0.23, 0,23)
		style.border_color = Color.WHITE
		style.set_border_width_all(2)
		slot.add_theme_stylebox_override("panel", style)
		
		var symbol = create_label("", 26, HORIZONTAL_ALIGNMENT_CENTER)
		symbol.add_theme_color_override("font_color", Color.WHITE)
		slot.add_child(symbol)
		
		grid.add_child(slot)
		storage.append(symbol)
	
		
func clear_dice_slots() -> void:
	for slot in attacker_dice_slots:
		if is_instance_valid(slot):
			slot.get_parent().queue_free()
	
	for slot in defender_dice_slots:
		if is_instance_valid(slot):
			slot.get_parent().queue_free()
	
	attacker_dice_slots.clear()
	defender_dice_slots.clear()


func _on_roll_pressed() -> void:
	if roll_button.disabled:
		return
	
	roll_button.disabled = true
	roll_requested.emit()


func animate_roll(
	attacker_result: Array[String], 
	defender_result: Array[String]
) -> void:
	var all_slots = attacker_dice_slots + defender_dice_slots
	
	for round in range(15):
		for slot in all_slots:
			slot.text = DICE_FACES.pick_random()
		
		await get_tree().create_timer(0.07).timeout
	
	for i in range(attacker_result.size()):
		attacker_dice_slots[i].text = attacker_result[i]
	
	for i in range(defender_result.size()):
		defender_dice_slots[i].text = defender_result[i]


func configure_health_bar(bar: ProgressBar) -> void:
	var fill = StyleBoxFlat.new()
	fill.bg_color = Color(0.1, 0.8, 0.1)
	
	var background = StyleBoxFlat.new()
	background.bg_color = Color(0.65, 0.1, 0.1)
	
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", background)


#func create_dice_slots(
	#amount: int,
	#storage: Array[Label],
	#unused: Variant
#) -> void:
	#pass
