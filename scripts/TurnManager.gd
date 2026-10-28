extends Node

signal turn_changed(actor: Node)
signal phase_changed(is_night: bool)
signal queue_changed

var all_actors: Array[Node] = []
var turn_queue: Array[Node] = []
var completed_actors: Array[Node] = []

var queue_started: bool = false
var current_turn_index: int = 0
var current_actor: Node = null
var is_night: bool = false	

func register_actor(actor: Node) -> void:
	if not is_instance_valid(actor):
		return
	
	if all_actors.has(actor):
		return
	
	all_actors.append(actor)
	
	#if queue_started:
		#rebuild_turn_queue()

	queue_changed.emit()

func start_queue() -> void:
	completed_actors.clear()
	current_turn_index = 0
	is_night = false
	#queue_started = true
	
	rebuild_turn_queue()
	
	if turn_queue.is_empty():
		current_actor = null
		return
	
	start_current_turn()

func rebuild_turn_queue() -> void:
	turn_queue.clear()
	
	for actor in all_actors:
		if not is_instance_valid(actor):
			continue
	
		if actor.has_method("can_act_during_phase"):
			if not actor.can_act_during_phase(is_night):
				continue
				
		turn_queue.append(actor)
	
	current_turn_index = 0
	queue_changed.emit()

func start_current_turn() -> void:
	if turn_queue.is_empty():
		current_actor = null
		return
	
	current_turn_index = current_turn_index % turn_queue.size()
	current_actor = turn_queue[current_turn_index]
	
	if current_actor.has_method("reset_ap"):
		current_actor.reset_ap()
		
	turn_changed.emit(current_actor)


func end_turn() -> void:
	if turn_queue.is_empty() or current_actor == null:
		return
	
	completed_actors.append(current_actor)
	current_turn_index += 1
	
	if current_turn_index >= turn_queue.size():
		is_night = not is_night
		completed_actors.clear()
		
		phase_changed.emit(is_night)
		rebuild_turn_queue()
	
	queue_changed.emit()
	start_current_turn()

func has_finished_turn(actor: Node) -> bool:
	return completed_actors.has(actor)
