class_name SensorSuite
extends ISensor2D

@export_range(0., 15.)
var ray_history_size := 5
@export_range(0, 10)
var number_of_ticks_to_skip_for_history := 2

@onready var ray_sensor: AdvancedRaycastSensor2D = %RaySensor
@onready var near_field_sensor: Area2D = %NearFieldSensor

var speed: float = 0.

var _ray_sensor_history: Array[Array]
var _rotation_history: Array[float]
var _speed_history: Array[Vector2]

var velocity: Vector2 = Vector2.ZERO
var _ticks_since_last_history := 0 


func _ready() -> void:
	reset()
	
func _draw() -> void:
	draw_line(self.position, velocity, Color.YELLOW, 2)
	var a := to_local(self.global_position + Vector2(0,-100).rotated(_rotation_history[0] * PI))
	draw_line(self.position, a, Color.YELLOW, 2)
	
func _physics_process(delta: float) -> void:
	_ticks_since_last_history = (_ticks_since_last_history + 1) % number_of_ticks_to_skip_for_history
	
	# push new observations into the history queue
	var obs := ray_sensor.get_observation()
	_ray_sensor_history.pop_back()
	_ray_sensor_history.push_front(obs)

	assert(
		_ray_sensor_history.size() == ray_history_size,
		"Something went wrong! The history is either too big or too small!"
	)
	
	# push new rotations into the rotation history queue
	_rotation_history.pop_back()
	_rotation_history.push_front(self.global_rotation / PI)

	# push the current speed into the speed history
	_speed_history.pop_back()
	var ship := (get_parent() as RigidBody2D) # TODO solve in a nicer way as accessing the parent is a NONO
	velocity = (ship.linear_velocity).rotated(-ship.global_rotation) # rotate the velocity into the local context
	_speed_history.push_front(velocity / 1000.)
	speed = velocity.length() / delta

	queue_redraw()
	
func reset():
	ray_sensor.reset()
	
	var ray_count: int = int(ray_sensor.n_rays) * 2 # *2 because we also track the type of entity
	_ray_sensor_history = []
	for i in range(ray_history_size):
		var observations := []
		observations.resize(ray_count)
		observations.fill(0)
		_ray_sensor_history.append(observations)
		
	_rotation_history.resize(ray_history_size)
	_rotation_history.fill(0.)
	
	_speed_history.resize(ray_history_size)
	_speed_history.fill(0.)
	velocity = Vector2.ZERO

func activate():
	ray_sensor.activate()
	
func deactivate():
	ray_sensor.deactivate()

func get_observation() -> Array:
	var all_obs := flatten(_ray_sensor_history)
	all_obs.append_array(_rotation_history)
	
	for old_speed in _speed_history:
		all_obs.append(old_speed.x)
		all_obs.append(old_speed.y)
	return all_obs
	
func get_near_field_objects_count() -> int:
	return near_field_sensor.get_overlapping_bodies().filter(func(b): return b is Asteroid).size()

static func flatten(nested: Array[Array]) -> Array:
	var flat = []
	for array in nested:
		flat.append_array(array)
	return flat
