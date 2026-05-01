extends Node2D

const MAX_ATTEMPTS := 50

var asteroid := preload("uid://tm3wubyfx7r")
var spawn_delay: int = 3 # seconds
var instances_max: int = 10
var spawn_force: float = 500.0 # tweak impulse strength

func _ready():
	randomize()
	var spawn_timer := Timer.new()
	spawn_timer.timeout.connect(spawn)
	add_child(spawn_timer)
	spawn_timer.start(spawn_delay)


func spawn():
	if get_children().size() >= instances_max:
		return
	var instance := asteroid.instantiate() as RigidBody2D
	var collision_shape := instance.get_node_or_null("CollisionShape2D")
	if not collision_shape or not collision_shape.shape:
		push_error("asteroid scene needs a CollisionShape2D with a Shape2D.")
		return

	# Try multiple edge samples until a free spot is found
	var last_position := Vector2.ZERO
	for i in range(MAX_ATTEMPTS):
		var spawn_position := _get_spawn_position()
		last_position = spawn_position
		if _is_position_free(collision_shape.shape, spawn_position):
			instance.position = spawn_position
			add_child(instance)
			_apply_spawn_impulse(instance)
			return
	# fallback: place at last sampled spawn_position even if overlap check failed
	instance.position = last_position
	add_child(instance)
	_apply_spawn_impulse(instance)


# Picks a spawn point outside the current viewport by chosing a random place on 
# the edge of the viewport scaled by a factor of 2.
func _get_spawn_position() -> Vector2:
	var viewport := get_viewport()
	var size = viewport.size
	var canvas_transform := viewport.get_canvas_transform()
	var edge := randi() % 4
	var spawn_point: Vector2
	match edge:
		0: spawn_point = Vector2(randf_range(0.0, size.x), -size.y)
		1: spawn_point = Vector2(size.x * 2.0, randf_range(0.0, size.y))
		2: spawn_point = Vector2(randf_range(0.0, size.x), size.y * 2.0)
		3: spawn_point = Vector2(-size.x, randf_range(0.0, size.y))
	
	return canvas_transform * spawn_point


# Overlap test using direct space state
func _is_position_free(shape: Shape2D, pos: Vector2, margin: float = 0.01) -> bool:
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, pos)
	params.margin = margin
	var space := get_world_2d().direct_space_state
	var res := space.intersect_shape(params, 1)
	return res.is_empty()


## Applies an impusle towards the center of the viewport with a random offset 
## between + and - 20 degrees.
func _apply_spawn_impulse(body: RigidBody2D) -> void:
	var viewport := get_viewport()
	var canvas_transform := viewport.get_canvas_transform()
	var viewport_center= canvas_transform * (viewport.size * 0.5)
	var base_direction = (viewport_center - body.position).normalized()
	var angle_offset = deg_to_rad(randf_range(-20.0, 20.0))
	var direction = base_direction.rotated(angle_offset)
	body.apply_central_impulse(direction * spawn_force)
