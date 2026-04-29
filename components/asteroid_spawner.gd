extends Node2D

const MAX_ATTEMPTS := 50

var asteroid := preload("uid://tm3wubyfx7r")
var spawn_delay: int = 3 # seconds
var instances_max: int = 10

func _ready():
	randomize()
	var spawn_timer := Timer.new()
	spawn_timer.timeout.connect(spawn)
	add_child(spawn_timer)
	spawn_timer.start(spawn_delay)

func spawn():
	if get_children().size() >= instances_max:
		return
	var instance := asteroid.instantiate() as Asteroid
	var collision_shape := instance.get_node_or_null("CollisionShape2D")
	if not collision_shape or not collision_shape.shape:
		push_error("asteroid scene needs a CollisionShape2D with a Shape2D.")
		return
	
	
	
	# Try multiple edge samples until a free spot is found
	var last_position := Vector2.ZERO
	for i in range(MAX_ATTEMPTS):
		var spawn_position := _get_random_point_on_canvas_edge()
		last_position = spawn_position
		if _is_position_free(collision_shape.shape, spawn_position):
			instance.position = spawn_position
			add_child(instance)
			return

	# fallback: place at last sampled spawn_position even if overlap check failed
	instance.position = last_position
	get_tree().current_scene.add_child(instance)


# Return a random point on the full viewport edge converted to world (canvas) coordinates.
func _get_random_point_on_canvas_edge() -> Vector2:
	var viewport := get_viewport()
	var size = viewport.size                           
	var canvas_transform := viewport.get_canvas_transform()

	var edge := randi() % 4
	var viewport_point: Vector2 
	match edge:
		0: viewport_point = Vector2(randf_range(0, size.x), 0)        # top
		1: viewport_point = Vector2(size.x, randf_range(0, size.y))   # right
		2: viewport_point = Vector2(randf_range(0, size.x), size.y)   # bottom
		3: viewport_point = Vector2(0, randf_range(0, size.y))        # left

	return canvas_transform * viewport_point
	
# Overlap test using direct space state
func _is_position_free(shape: Shape2D, pos: Vector2, margin: float = 0.01) -> bool:
		var params := PhysicsShapeQueryParameters2D.new()
		params.shape = shape
		params.transform = Transform2D(0.0, pos)       
		params.margin = margin
		var space := get_world_2d().direct_space_state
		var res := space.intersect_shape(params, 1) 
		return res.is_empty()
