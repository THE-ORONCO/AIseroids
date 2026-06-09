class_name Shot
extends RigidBody2D

@export_range(1.,3000.) var speed: float = 1500.
@export_range(0., 5.) var despawn_after: float = 1.
@export_range(1., 10.) var damage: int = 1
@export var team: Fight.Team = Fight.Team.BLUE:
	set(val):
		if sprite: sprite.frame = val
		team = val
@onready var despawn_timer: Timer = %DespawnTimer
@onready var sprite: Sprite2D = %Sprite


func _ready() -> void:
	self.linear_velocity = self.transform.y * -speed
	despawn_timer.start(despawn_after)
	body_entered.connect(func(_a): self.queue_free())
	sprite.frame = team


func _on_despawn_timer_timeout() -> void:
	self.queue_free()
 
