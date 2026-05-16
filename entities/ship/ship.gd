class_name Ship
extends RigidBody2D

signal health_changed(new_health: int)
signal health_reached_zero


@export_range(0, 20) var max_health: int = 10

@export_group("internals")
@export var controller: ShipController
@export var health_manager: HealthManager = null

@export_group("movement")
@export_range(1., 3000.) var thruster_power: float = 500.
@export_range(1., 3000.) var strafe_power: float = 500.
@export_range(.1, 10.) var rotation_speed: float = 6.
@export_range(1., 5000.) var max_velocity: float = 1000.
@export_range(1., 5000.) var max_force: float = 1000.

@onready var thruster_particles: GPUParticles2D = $ThrusterParticles
@onready var muzzle: Muzzle = %Muzzle
@onready var sensor_suit: SensorSuite = %SensorSuite
@onready var health_bar: HealthBar = %HealthBar
@onready var invincibility_timer: Timer = %InvincibilityTimer

const DEFAULT_MUZZLE: PackedScene = preload("uid://c2qcohstk8elv")

## resets the ship to its base state.
## the reset_position is in global coordinates
func reset_ship(reset_position: Vector2 = Vector2.ZERO) -> void:
	health_manager.reset_health()
	muzzle.reset_weapon()
	self.set_deferred("linear_velocity", Vector2.ZERO)
	self.set_deferred("angular_velocity", 0.)
	self.set_deferred("rotation", 0.)
	self.set_deferred("global_position", reset_position)
	

func _ready() -> void:
	if !controller:
		controller = PlayerController.new()
		self.add_child(controller)
	
	controller.sensor = sensor_suit

	if health_manager == null:
		health_manager = HealthManager.new(self, 10)
	health_bar.set_up_progress_bar(health_manager)
	if not self.body_entered.is_connected(_check_for_damage):
		self.body_entered.connect(_check_for_damage)
	
	health_manager.health_reached_zero.connect(health_reached_zero.emit)
	health_manager.health_changed.connect(func(nh): 
		controller.health = nh
		health_changed.emit(nh)
		)

func _physics_process(delta: float) -> void:
	_rotate(delta)
	_thrust()
	_strafe()
	_fire()
	
	_update_ship_info()
	
	self.linear_velocity = self.linear_velocity.normalized() * clamp(linear_velocity.length(), 0 , max_velocity) 
	
func _update_ship_info() -> void:
	controller.shots_max = muzzle.max_shots
	controller.current_shots = muzzle.current_shots
	controller.time_till_reload = muzzle.time_till_reload
	controller.shot_cooldown = muzzle.cooldown_left

func _rotate(delta: float) -> void:
	var rotation_input: float = controller.turn
	if abs(rotation_input) >= 0.1 :
		self.rotate(rotation_input * rotation_speed * delta)

func _thrust() -> void:
	var thrust_input := controller.thrust
	if thrust_input > 0:
		var thrust := (Vector2.UP * thruster_power * thrust_input).rotated(self.rotation)
		self.apply_central_force(thrust)
		thruster_particles.emitting = true
	else: 
		thruster_particles.emitting = false

func _strafe() -> void:
	var strafe := Input.get_axis(&"strafe_left", &"strafe_right")
	self.apply_central_force(self.transform.x * strafe * strafe_power)

func _fire() -> void:
	if controller.shoot:
		muzzle.fire(self.linear_velocity)

func _check_for_damage(body: Node) -> void:
	print("check")
	if body.is_in_group(&"DamageCollider"):
		if invincibility_timer.is_stopped():
			print(body.damage)
			health_manager.apply_health_change(-(body.damage))
			invincibility_timer.start()
			print("took damage")
		else:
			print("invincible")
		# TODO apply force to both rigid bodies to push them appart
