class_name Shot
extends RigidBody2D

@export_range(1.,3000.) var speed: float = 1500.
@export_range(0., 5.) var despawn_after: float = 1.
@export_range(1., 10.) var damage: int = 1
@export var team: S_Team:
	set(val):
		_apply_team_color(val)
		team = val
@onready var despawn_timer: Timer = %DespawnTimer
@onready var sprite: Sprite2D = %Sprite


func _ready() -> void:
	setup()

func setup() -> void:
	self.linear_velocity = self.transform.y * -speed
	despawn_timer.start(despawn_after)
	body_entered.connect(func(_a): self.queue_free())
	_apply_team_color(team)

func configure(blueprint: S_Shot, shooting_team: S_Team) -> void:
	if blueprint: 
		self.speed = blueprint.speed
		self.despawn_after = blueprint.despawn_after
		self.damage = blueprint.damage
		self.mass = blueprint.mass
	if shooting_team:
		self.team = shooting_team
	setup()

func _apply_team_color(shooting_team: S_Team) -> void:
	if !sprite || !shooting_team:
		return
	sprite.modulate = shooting_team.color

func _on_despawn_timer_timeout() -> void:
	self.queue_free()
 
