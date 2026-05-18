class_name Muzzle
extends Marker2D

@onready var shot: PackedScene = preload("uid://bgqdgtlshk4yf")
@export_range(1., 100.) var max_shots: int = 5
@export_range(0.01, 2.) var cooldown: float = .3
@export_range(0.1, 3.) var reload_time: float = 1.

@onready var shot_cooldown_timer: Timer = %ShotCooldown
@onready var reload_timer: Timer = %ReloadTimer

var _current_shots: int = 0

var current_shots: int:
	get: return _current_shots
var cooldown_left: float:
	get: return shot_cooldown_timer.time_left
var time_till_reload: float:
	get: return reload_timer.time_left

func _ready() -> void:
	reset_weapon()
	reload_timer.timeout.connect(_reload)

func get_state_for_ai() -> Array:
	return [
		max_shots,
		_current_shots,
		shot_cooldown_timer.time_left,
		reload_timer.time_left,
	]

func fire(reference_velocity: Vector2) -> void:
	if !shot_cooldown_timer.is_stopped():
		#print("the weapon is on cooldown")
		return
	if _current_shots <= 0 :
		#print("no bullets left!")
		return 

	var bullet: Shot = shot.instantiate()
	bullet.add_to_group("SplitsAsteroids")
	if bullet.damage > 0:
		bullet.add_to_group("DamageCollider")
	bullet.transform = self.global_transform
	bullet.linear_velocity = reference_velocity  

	get_tree().root.add_child(bullet)
	
	_current_shots -= 1
	shot_cooldown_timer.start()
	
	if reload_timer.is_stopped():
		reload_timer.start()
	
## Resets the weapon to its default state (completelly loaded and timers on max cooldown)
func reset_weapon() -> void:
	_current_shots = max_shots
	
	shot_cooldown_timer.wait_time = cooldown
	shot_cooldown_timer.stop()
	reload_timer.wait_time = reload_time
	reload_timer.stop()
	
	for shot: Shot in get_tree().root.get_children().filter(func(c): return c is Shot):
		shot.queue_free()

func _reload() -> void:
	self._current_shots = move_toward(_current_shots, max_shots, 1)
	if _current_shots >= max_shots:
		reload_timer.stop()
