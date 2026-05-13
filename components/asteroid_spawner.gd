extends Node2D


const MAX_ATTEMPTS := 50
const ASTEROID = preload("uid://tm3wubyfx7r")

@export var wrap_instance: Wrap

var instances_max: int = 100
var spawn_force: float = 500.0
var spawns: bool = true
var rng: RandomNumberGenerator
var spawn_timer: Timer


func _ready() -> void:
	if wrap_instance == null:
		push_error("No wrap assigned. Spawn position cannot be calculated")
		spawns = false
	rng = RandomNumberGenerator.new()


func spawn_wave(wave_size: int, spawn_delay: float) -> void:
	if wave_size < 1:
		return
	for i in range(wave_size):
		get_tree().create_timer(spawn_delay * (i+1)).timeout.connect(spawn)


func spawn() -> void:
	if not spawns:
		return
	if get_children().size() >= instances_max:
		return
	var instance := ASTEROID.instantiate() as Asteroid
	add_child(instance)
	var collision_shape := instance.get_node_or_null("CollisionShape2D")
	if not collision_shape or not collision_shape.shape:
		push_error("ASTEROID scene needs a CollisionShape2D with a CircleShape2D.")
		return
	
	var last_position := Vector2.ZERO
	var edge = 0
	for i in range(MAX_ATTEMPTS):
		edge = rng.randi() % 4
		var spawn_position := _get_spawn_position(instance.collision_shape_2d.shape.radius, edge)
		last_position = spawn_position
		if _is_position_free(collision_shape.shape, spawn_position):
			instance.position = spawn_position
			add_child(instance)
			_apply_spawn_impulse(instance, edge)
			return
	
	# fallback: place at last sampled spawn_position even if overlap check failed
	instance.position = last_position
	_apply_spawn_impulse(instance, edge)


# Picks a spawn point outside the current wrap by chosing a random place on 
# the edge of the wrap and adding an offset so the ASTEROID is spawned outside.
func _get_spawn_position(asteroid_radius: float, edge: int) -> Vector2:
	var viewport := get_viewport()
	var canvas_transform := viewport.get_canvas_transform()
	var spawn_point: Vector2
	var spawn_offset = asteroid_radius + 50 
	var wrap_top = wrap_instance.position.y - spawn_offset
	var wrap_right = wrap_instance.position.x + wrap_instance.extent.x + spawn_offset
	var wrap_bottom = wrap_instance.position.y + wrap_instance.extent.y + spawn_offset
	var wrap_left = wrap_instance.position.x - spawn_offset
	match edge:
		0: spawn_point = Vector2(randf_range(wrap_left, wrap_right), wrap_top)
		1: spawn_point = Vector2(wrap_left, randf_range(wrap_top, wrap_bottom))
		2: spawn_point = Vector2(randf_range(wrap_left, wrap_right), wrap_bottom)
		3: spawn_point = Vector2(wrap_right, randf_range(wrap_top, wrap_bottom))
	
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


## Applies an impusle towards the center of the wrap with a random offset 
## between + and - 20 degrees.
func _apply_spawn_impulse(body: RigidBody2D, edge: int) -> void:
	var target_pos: Vector2
	var wrap_top: float = wrap_instance.position.y 
	var wrap_right: float = wrap_instance.position.x + wrap_instance.extent.x
	var wrap_bottom: float = (wrap_instance.position + wrap_instance.extent).y
	var wrap_left: float = wrap_instance.position.x
	match edge:
		0: target_pos = Vector2(randf_range(wrap_left, wrap_right),wrap_bottom)
		1: target_pos = Vector2(wrap_right, randf_range(wrap_top, wrap_bottom))
		2: target_pos = Vector2(randf_range(wrap_left, wrap_right), wrap_top)
		3: target_pos = Vector2(wrap_left, randf_range(wrap_top, wrap_bottom))
	var direction = target_pos - body.position
	body.apply_central_impulse(direction.normalized() * spawn_force)
