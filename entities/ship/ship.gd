extends RigidBody2D

@export var thruster_power: float = 20.
@export var rotation_speed: float = 80.
@onready var thruster_particles: GPUParticles2D = $ThrusterParticles

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		var thrust = (Vector2.UP * thruster_power).rotated(self.rotation)
		self.apply_central_force(thrust)
		thruster_particles.emitting = true
	else: 
		thruster_particles.emitting = false

	var rotation_input: float = Input.get_axis("ui_left", "ui_right")
	if abs(rotation_input) >= 0.1 :
		self.apply_torque(rotation_input * rotation_speed)
