class_name Shot
extends RigidBody2D

@export_range(1,3000) var speed: float = 1500.

func _ready() -> void:
	self.linear_velocity = self.transform.y * -speed
