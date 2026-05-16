class_name Asteroid
extends RigidBody2D


const ASTEROID: PackedScene = preload("uid://tm3wubyfx7r")

var splits: bool = false

## TODO remove
var damage := 1 

## Amount of asteroids generated on split
@export var split_count: int = 3:
	set(value): 
		value = clamp(value, 1, 6)
		split_count = value
@export var split_force: int = 300
@export var split_delay: float = 0.5 # seconds
@export var impulse_threshold: float = 300.0  # impulse threshold to trigger split
@export var min_radius: float = 10.
@export var bus: SignalBus
@export var mass_size_ratio: float = 0.1

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var icon: Sprite2D = $Icon
@onready var despawn_check_timer: Timer = %DespawnCheckTimer


func _ready() -> void:
	get_tree().create_timer(split_delay).timeout.connect(func(): splits = true)
	
	var radius: float = collision_shape_2d.shape.radius
	self.mass = ((PI * radius * radius) / 1000) * mass_size_ratio
	self.angular_velocity = randf_range(-1., 1.)
	
	if collision_shape_2d.shape is not CircleShape2D:
		push_warning("collison shape is not a circle")
		splits = false
		
	despawn_check_timer.timeout.connect(func():
		if self.position.length() > 5000: # despawn asteroid if it is too far away
			self.queue_free()
		)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var contact_count := state.get_contact_count()
	for i in range(contact_count):
		var collider_obj := state.get_contact_collider_object(i)
		if not collider_obj:
			continue
		if collider_obj.is_in_group("SplitsAsteroids"):
			split()
			return
		if collider_obj is Asteroid:
			var impulse_vec := state.get_contact_impulse(i)
			if impulse_vec.length() >= impulse_threshold:
				split()
				return

## try to split the asteroid, destroy it, if it is small engough
func split() -> void:
	var radius: float = collision_shape_2d.shape.radius

	if bus:
		bus.signal_asteroid_destoryed(radius)
		
	if not splits:
		return
	
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
		asteroid_instance.bus = bus
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
	

	self.queue_free()

# see https://en.wikipedia.org/wiki/Circle_packing_in_a_circle
func _calc_circle_radius(circle_count: int) -> float:
	match circle_count:
		2: return 1. / 2.
		3: return 1. / (1. + (2. / sqrt(3.)))
		4: return 1. / (1. + sqrt(2.))
		5: return 1. / (1. + sqrt(2. * (1. + (1. / sqrt(5.)))))
		6: return 3.
		_: return 1.
