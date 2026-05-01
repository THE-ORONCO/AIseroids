class_name Asteroid
extends RigidBody2D


const ASTEROID = preload("uid://tm3wubyfx7r")

var splits: bool = true

## TODO remove
var damage := 1 

## Amount of asteroids generated on split
@export var split_count: int = 5:
	set(value): 
		value = clamp(value, 1, 6)
		split_count = value
@export var split_force: int = 500
@export var min_radius: float = 10

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var icon: Sprite2D = $Icon


func _ready() -> void:
	if collision_shape_2d.shape is not CircleShape2D:
		push_warning("collison shape is not a circle")
		splits = false
	if not body_entered.is_connected(split):
		body_entered.connect(split)


func split(body: Node) -> void:
	if not (body.is_in_group("SplitsAsteroids") and splits):
		return
	var radius: float = collision_shape_2d.shape.radius
	var rotation_delta: float = 2. * PI / split_count
	var random_rotatation :=  RandomNumberGenerator.new().randf()
	var unit_circle_radius := _calc_circle_radius(split_count)
	var new_radius := radius * unit_circle_radius
	if new_radius < min_radius:
		self.queue_free()
		return
	var original_direction: Vector2 = self.get_linear_velocity().normalized()
	if original_direction == Vector2.ZERO:
		original_direction = Vector2.UP
	for i in range(split_count):
		var asteroid_instance := ASTEROID.instantiate() as Asteroid
		var new_collision_shape := CircleShape2D.new()
		var push_direction := original_direction.rotated(
			rotation_delta * i * random_rotatation
		)
		get_parent().add_child.call_deferred(asteroid_instance)
		await asteroid_instance.ready
		asteroid_instance.icon.apply_scale(self.icon.scale * unit_circle_radius)
		new_collision_shape.radius = new_radius
		asteroid_instance.collision_shape_2d.shape = new_collision_shape
		asteroid_instance.position = position + push_direction * (radius - new_radius)
		asteroid_instance.apply_central_impulse(push_direction * split_force)
	
	SignalBus.signal_asteroid_destoryed(radius)
	self.queue_free()


func _calc_circle_radius(circle_count: int) -> float:
	match circle_count:
		2: return 1. / 2.
		3: return 1. / (1. + (2. / sqrt(3.)))
		4: return 1. / (1. + sqrt(2.))
		5: return 1. / (1. + sqrt(2. * (1. + (1. / sqrt(5.)))))
		6: return 3.
		_: return 1.
