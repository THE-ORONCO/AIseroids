class_name RayWrap extends Area2D

var extent: Vector2
var ship_size: float
var epsilon: float = 1.


func wrap_ray(pos: Vector2, target: Vector2) -> Vector2:
	var wrap_delta: Vector2 = Vector2.ZERO
	pos = to_local(pos)
	target = to_local(target)

	if pos.x < 0.0 - ship_size + epsilon: # moving left
		wrap_delta.x += extent.x + ship_size * 2. - epsilon
	elif pos.x > extent.x + ship_size - epsilon: # moving right
		wrap_delta.x -= extent.x + ship_size * 2. - epsilon

	elif pos.y < 0.0 - ship_size + epsilon: # moving up
		wrap_delta.y += extent.y + ship_size * 2. - epsilon
	elif pos.y > extent.y + ship_size - epsilon: # moving down
		wrap_delta.y -= extent.y + ship_size * 2. - epsilon
	
	return wrap_delta
