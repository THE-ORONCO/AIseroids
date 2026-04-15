class_name MoveUtils 
extends Node



static func screen_wrap(position: Vector2, extent: Vector2) -> Vector2:
	var new_pos: Vector2 = position
	if position.x > extent.x: 	new_pos.x = 0
	elif position.x < 0: 		new_pos.x = extent.x
	if position.y > extent.y: 	new_pos.y = 0
	elif position.y < 0: 		new_pos.y = extent.y 

	return new_pos
