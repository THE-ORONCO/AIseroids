class_name Ship
extends RigidBody2D

@export var ship_controller: ShipController

@export_group("movement")
@export_range(1, 3000) var thruster_power: float = 500.
@export_range(1, 3000) var strafe_power: float = 500.
@export_range(.1, 5.) var rotation_speed: float = 3.
@export_range(1, 5000) var max_velocity: float = 1000.
@export_range(1, 5000) var max_force: float = 1000.
@export_group("shooting")
@export var shot: PackedScene

@onready var thruster_particles: GPUParticles2D = $ThrusterParticles
@onready var muzzle: Marker2D = %Muzzle
@onready var sensor_suit: SensorSuite = %SensorSuite

func _ready() -> void:
	ship_controller.sensor = sensor_suit

func _physics_process(delta: float) -> void:
	_rotate(delta)
	_thrust()
	_strafe()
	_fire()
		
	self.linear_velocity = self.linear_velocity.normalized() * clamp(linear_velocity.length(), 0 , max_velocity) 
	
func _rotate(delta: float) -> void:
	var rotation_input: float = ship_controller.turn
	if abs(rotation_input) >= 0.1 :
		self.rotate(rotation_input * rotation_speed * delta)

func _thrust() -> void:
	var thrust_input := ship_controller.thrust
	if thrust_input > 0:
		var thrust = (Vector2.UP * thruster_power * thrust_input).rotated(self.rotation)
		self.apply_central_force(thrust)
		thruster_particles.emitting = true
	else: 
		thruster_particles.emitting = false

func _strafe() -> void:
	var strafe := Input.get_axis("strafe_left", "strafe_right")
	self.apply_central_force(self.transform.x * strafe * strafe_power)

func _fire() -> void:
	if ship_controller.shoot:
		var bullet: Shot = shot.instantiate()
		bullet.add_to_group("SplitsAsteroids")
		bullet.transform = muzzle.global_transform
		bullet.linear_velocity = self.linear_velocity
		get_parent().add_child(bullet)
