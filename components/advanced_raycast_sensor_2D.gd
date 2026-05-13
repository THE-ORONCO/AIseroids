@tool
class_name AdvancedRaycastSensor2D
extends ISensor2D

@export_flags_2d_physics var collision_mask := 1:
	get:
		return collision_mask
	set(value):
		collision_mask = value
		_update()

@export var collide_with_areas := false:
	get:
		return collide_with_areas
	set(value):
		collide_with_areas = value
		_update()

@export var collide_with_bodies := true:
	get:
		return collide_with_bodies
	set(value):
		collide_with_bodies = value
		_update()

@export var n_rays := 16.0:
	get:
		return n_rays
	set(value):
		n_rays = value
		_update()

@export_range(5, 3000, 5.0) var ray_length := 200:
	get:
		return ray_length
	set(value):
		ray_length = value
		_update()
@export_range(5, 360, 5.0) var cone_width := 360.0:
	get:
		return cone_width
	set(value):
		cone_width = value
		_update()

@export var debug_draw := true:
	get:
		return debug_draw
	set(value):
		debug_draw = value
		_update()

var _angles = []
var _froms: Array[Vector2]= []
var _tos: Array[Vector2]= []

var rays :Array[RayCast2D]= []


func _update():
	if Engine.is_editor_hint():
		if debug_draw:
			_spawn_nodes()
		else:
			for ray in get_children():
				if ray is RayCast2D:
					remove_child(ray)


func _draw() -> void:
	var debug_count := _froms.size()
	for i in range(debug_count):
		var from := to_local(_froms[i])
		var to := to_local(_tos[i])
		var col := Color.RED.lerp(Color.BLUE, float(i) / float(debug_count))
		draw_line(from, to, col, 2)

func _ready() -> void:
	_spawn_nodes()


func _spawn_nodes():
	for ray in rays:
		ray.queue_free()
	rays = []

	_angles = []
	var step = cone_width / (n_rays)
	var start = step / 2 - cone_width / 2

	for i in n_rays:
		var angle = start + i * step
		var ray = RayCast2D.new()
		ray.set_target_position(
			Vector2(ray_length * cos(deg_to_rad(angle)), ray_length * sin(deg_to_rad(angle)))
		)
		ray.set_name("node_" + str(i))
		ray.enabled = false
		ray.collide_with_areas = collide_with_areas
		ray.collide_with_bodies = collide_with_bodies
		ray.collision_mask = collision_mask
		add_child(ray)
		rays.append(ray)

		_angles.append(start + i * step)


func get_observation() -> Array:
	return self.calculate_raycasts()


func calculate_raycasts() -> Array:
	var result = []
	var distances: Array[float] = []
	var types: Array[ShapeId.EntityType] = []
	
	if debug_draw:
		_froms.clear()
		_tos.clear()
		queue_redraw()

	var state := get_world_2d().get_direct_space_state()
	
	for ray: RayCast2D in rays:
		var from := ray.global_position
		var delta := ray.position + ray.target_position
		var to := from + delta
		
		var cast_result: Dictionary = _cast_wrapping(from, to, ray.collision_mask)

		var distance := 0.0
		if cast_result:
			var length: float = (ray.global_position - cast_result.position).length()
			length = clamp(distance, 0.0, ray_length)
			distance =  (ray_length - length) / ray_length
		# _get_raycast_distance(ray)
		distances.append(distance)
		
		var shape_type: ShapeId.EntityType = ShapeId.EntityType.NOTHING
		if cast_result:
			var collider = cast_result.collider
			shape_type = ShapeId.identify(collider)
		types.append(shape_type)
		
		
		ray.enabled = false
	
	result.append_array(distances)
	result.append_array(types)
	
	return result

func _cast_wrapping(from: Vector2, to: Vector2, mask: int, max_depth := 3, depth := 0) -> Dictionary:
	if depth > max_depth:
		return {}

	var state := get_world_2d().get_direct_space_state()
	var query:= PhysicsRayQueryParameters2D.create(from, to)
	query.collision_mask = mask
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result: Dictionary = state.intersect_ray(query)
	
	_froms.append(from)

	if result:
		_tos.append(result.position)

		if result.collider is RayWrap:
			var wrap: RayWrap = result.collider
			var hit_pos: Vector2 = result.position
			var direction := (to - from).normalized()
			var shift_delta := wrap.wrap_ray(hit_pos, to)
			return _cast_wrapping(hit_pos + shift_delta, to + shift_delta, mask, 3, depth + 1)
		else:
			return result
	else:
		_tos.append(to)
		return {}


func _get_raycast_distance(ray: RayCast2D) -> float:
	if !ray.is_colliding():
		return 0.0

	var distance = (global_position - ray.get_collision_point()).length()
	distance = clamp(distance, 0.0, ray_length)
	return (ray_length - distance) / ray_length
