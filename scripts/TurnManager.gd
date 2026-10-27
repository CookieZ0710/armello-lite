extends Node

signal turn_changed(actor: Node)
signal phase_changed(is_night: bool)

var turn_queue: Array[Node] = []
var current_turn_index: int = 0
var current_actor: Node = null
var is_night: bool = false	

func setup(queue: Array[Node]) -> void:
	turn_queue = queue
	current_turn_index = 0
	is_night = false
	
	start_current_turn()



func start_current_turn() -> void:
	if turn_queue.is_empty():
		current_actor = null
		return
	
	current_actor = turn_queue[current_turn_index]
	
	if current_actor.has_method("reset_ap"):
		current_actor.reset_ap()
		
	turn_changed.emit(current_actor)


func end_turn() -> void:
	if turn_queue.is_empty():
		return
	
	current_turn_index += 1
	
	if current_turn_index >= turn_queue.size():
		current_turn_index = 0
		is_night = not is_night
		phase_changed.emit(is_night)
	
	start_current_turn()
