class_name Asteroid
extends RigidBody2D


const ASTEROID = preload("uid://tm3wubyfx7r")


var _screen_size: Vector2:
	get: return self.get_viewport_rect().size
var splits: bool = true

## Amount of asteroids generated on split
@export var split_count: int = 2:
	set(value): 
		value = clamp(value, 1, 6)
		split_count = value

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var icon: Sprite2D = $Icon


func _ready() -> void:
	if collision_shape_2d.shape is not CircleShape2D:
		push_warning("collison shape is not a circle")
		splits = false
	if not body_entered.is_connected(split):
		body_entered.connect(split)


func _physics_process(_delta: float) -> void:
	self.global_position = MoveUtils.screen_wrap(self.global_position, _screen_size)


func split(body: Node) -> void:
	if not (body.is_in_group("SplitsAsteroids") and splits):
		return
	var radius: float = collision_shape_2d.shape.radius
	var rotation_delta: float = 2. * PI / split_count
	var rng = RandomNumberGenerator.new()
	var random_rotatation := rng.randf()
	for i in range(split_count):
		var asteroid_instance := ASTEROID.instantiate() as Asteroid
		var unit_circle_radius := _calc_circle_radius(split_count)
		var new_radius := radius * unit_circle_radius
		var original_direction: Vector2 = self.get_linear_velocity().normalized()
		if original_direction == Vector2.ZERO:
			original_direction = Vector2.UP
		var push_direction := original_direction.rotated(
			rotation_delta * i * random_rotatation
		)
		get_parent().add_child.call_deferred(asteroid_instance)
		await asteroid_instance.ready
		asteroid_instance.icon.apply_scale(self.scale * unit_circle_radius)
		asteroid_instance.collision_shape_2d.shape.radius = new_radius
		asteroid_instance.position = position + push_direction * (radius - new_radius)
		asteroid_instance.apply_central_impulse(push_direction)
		self.queue_free()


func _calc_circle_radius(circle_count: int) -> float:
	match circle_count:
		2: return 1. / 2.
		3: return 1. / (1. + (2. / sqrt(3.)))
		4: return 1. / (1. + sqrt(2.))
		5: return 1. / 1. + sqrt(2. * (1. + (1. / sqrt(5.))))
		6: return 3.
		_: return 1.
