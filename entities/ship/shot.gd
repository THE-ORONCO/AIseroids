class_name Shot
extends RigidBody2D

@export_range(1.,3000.) var speed: float = 1500.
@export_range(0., 5.) var despawn_after: float = 1.
@export_range(1., 10.) var damage: int = 1
@export var team: Fight.Team = Fight.Team.BLUE:
	set(val):
		_apply_team_color(val)
		team = val
@onready var despawn_timer: Timer = %DespawnTimer
@onready var sprite: Sprite2D = %Sprite


func _ready() -> void:
	self.linear_velocity = self.transform.y * -speed
	despawn_timer.start(despawn_after)
	body_entered.connect(func(_a): self.queue_free())
	_apply_team_color(team)


func _apply_team_color(team: Fight.Team) -> void:
	if !sprite:
		return
	match team:
			Fight.Team.BLUE:
				sprite.modulate = Color.BLUE
			Fight.Team.RED:
				sprite.modulate = Color.RED
			Fight.Team.GREEN:
				sprite.modulate = Color.GREEN
			_:
				sprite.modulate = Color.WHITE


func _on_despawn_timer_timeout() -> void:
	self.queue_free()
 
