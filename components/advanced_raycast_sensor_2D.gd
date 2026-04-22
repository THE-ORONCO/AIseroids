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
var rays := []


func _update():
	if Engine.is_editor_hint():
		if debug_draw:
			_spawn_nodes()
		else:
			for ray in get_children():
				if ray is RayCast2D:
					remove_child(ray)


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
	
	for ray: RayCast2D in rays:
		ray.enabled = true
		ray.force_raycast_update()
		
		var collider := ray.get_collider()
		if collider is Wrap:
			var wrap: Wrap = collider
			
			var global_target := ray.global_position + ray.target_position
			
		
		var distance = _get_raycast_distance(ray)
		distances.append(distance)
		
		#var collider = ray.get_collider()
		types.append(ShapeId.identify(collider))
		
		ray.enabled = false
	
	result.append_array(distances)
	result.append_array(types)
	
	return result


func _get_raycast_distance(ray: RayCast2D) -> float:
	if !ray.is_colliding():
		return 0.0

	var distance = (global_position - ray.get_collision_point()).length()
	distance = clamp(distance, 0.0, ray_length)
	return (ray_length - distance) / ray_length
