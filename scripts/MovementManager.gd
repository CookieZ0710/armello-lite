extends Node

func move_entity(entity: Node, destination: Vector2i, map_manager: Node) -> bool:
	if not map_manager.hex_tiles.has(destination):
		return false
		
	if destination not in map_manager.get_neighbors(entity.coordinates):
		return false
		
	if map_manager.get_occupied_coordinates(entity).has(destination):
		return false
		
	var tile = map_manager.hex_tiles[destination]
	var movement_cost = tile.tile_data.movement_cost
	
	if entity.has_method("spend_ap"):
		if not entity.spend_ap(movement_cost):
			return false
	
	entity.coordinates = destination
	entity.position = tile.position
	
	if entity.has_method("change_health"):
		entity.change_health(tile.tile_data.health_change)
		
	print("Moved onto new Tile")
	print("Type: ", tile.tile_data.display_name)
	print("Movement Cost: ", movement_cost)
	print("Health Change: ", tile.tile_data.health_change)
	print("Coordinates: ", destination)
	
	return true
