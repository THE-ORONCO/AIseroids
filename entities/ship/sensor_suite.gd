class_name SensorSuite
extends ISensor2D

@export_range(0, 15) 
var ray_history_size := 5

@onready var ray_sensor: AdvancedRaycastSensor2D = %RaySensor

var _ray_sensor_history: Array[Array]

func _ready() -> void:
	reset()
	
func _physics_process(_delta: float) -> void:
	var obs := ray_sensor.get_observation()
	_ray_sensor_history.pop_back()
	_ray_sensor_history.push_front(obs)
	assert(
		_ray_sensor_history.size() == ray_history_size,
		"Something went wrong! The history is either too big or too small!"
	)

func reset():
	ray_sensor.reset()
	
	var ray_count: int = int(ray_sensor.n_rays) * 2 # *2 because we also track the type of entity
	_ray_sensor_history = []
	for i in range(ray_history_size):
		var observations := []
		observations.resize(ray_count)
		observations.fill(0)
		_ray_sensor_history.append(observations)

func activate():
	ray_sensor.activate()
	
func deactivate():
	ray_sensor.deactivate()

func get_observation() -> Array:
	return flatten(_ray_sensor_history)
	
static func flatten(nested: Array[Array]) -> Array:
	var flat = []
	for array in nested:
		flat.append_array(flat)
	return flat
