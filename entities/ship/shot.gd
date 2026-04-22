class_name Shot
extends RigidBody2D

@export_range(1,3000) var speed: float = 1500.
@export_range(0., 5.) var despawn_after: float = 1.
@onready var despawn_timer: Timer = %DespawnTimer

func _ready() -> void:
	self.linear_velocity = self.transform.y * -speed
	despawn_timer.wait_time = despawn_after


func _on_despawn_timer_timeout() -> void:
	self.queue_free()
