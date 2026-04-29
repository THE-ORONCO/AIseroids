class_name Muzzle
extends Marker2D

@export var shot: PackedScene
@export_range(1, 100) var max_bullets: int = 5
@export_range(0.01, 2.) var cooldown: float = .3
@export_range(0.1, 3.) var reload_time: float = 1.

@onready var shot_cooldown: Timer = %ShotCooldown
@onready var reload_timer: Timer = %ReloadTimer

var _current_bullets: int = 0

func _ready() -> void:
	_current_bullets = max_bullets
	shot_cooldown.wait_time = cooldown
	reload_timer.wait_time = reload_time
	reload_timer.timeout.connect(_reload)

func fire(reference_velocity: Vector2) -> void:
	if _current_bullets <= 0 :
		print("no bullets left!")
		return 
	if !shot_cooldown.is_stopped():
		print("the weapon is on cooldown")
		return

	var bullet: Shot = shot.instantiate()
	bullet.add_to_group("SplitsAsteroids")
	if bullet.damage > 0:
		bullet.add_to_group("DamageCollider")
	bullet.transform = self.global_transform
	bullet.linear_velocity = reference_velocity  

	get_tree().root.add_child(bullet)

func _reload() -> void:
	self._current_bullets = move_toward(_current_bullets, max_bullets, 1)
	
