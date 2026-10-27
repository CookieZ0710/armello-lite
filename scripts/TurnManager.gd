extends Node

signal turn_changed(actor: Node)
signal phase_changed(is_night: bool)

var turn_queue: Array[Node] = []
var current_turn_index: int = 0
var current_actor: Node = null
var is_night: bool = false	

func setup(queue: Array[Node]) -> void:
	print("=== TurnManager Setup ===")
	print("Received queue: ", queue)
	print("Queue size: ", queue.size())
	
	turn_queue = queue
	current_turn_index = 0
	is_night = false
	
	start_current_turn()



func start_current_turn() -> void:
	#print("=== Starting Turn ===")
	#print("Queue size: ", turn_queue.size())
	#print("Current index: ", current_turn_index)

	if turn_queue.is_empty():
		#push_error("Turn queue is empty!")
		current_actor = null
		return
	
	current_actor = turn_queue[current_turn_index]
	#print("Current actor: ", current_actor)	
#
	#if current_actor == null:
		#push_error("Current actor is null inside the turn queue!")
		#return
	
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
