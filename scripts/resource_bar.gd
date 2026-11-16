extends PanelContainer

var player: Node = null

@onready var AP_label: Label = $MainLayout/APLabel

func update_resource() -> void:
	if not is_instance_valid(player):
		return
		
	AP_label.text = "AP: %d / %d" % [
		player.current_ap,
		player.max_ap
	]
