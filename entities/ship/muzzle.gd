class_name Muzzle
extends Marker2D

const SHOT: PackedScene = preload("uid://bgqdgtlshk4yf")

@export_range(1., 100.) var max_shots: int = 5
@export_range(0.01, 2.) var cooldown: float = .3
@export_range(0.1, 3.) var reload_time: float = 1.

@onready var shot_cooldown_timer: Timer = %ShotCooldown
@onready var reload_timer: Timer = %ReloadTimer
@onready var pew: AudioStreamPlayer = %Pew
@onready var out_of_ammo: AudioStreamPlayer = $OutOfAmmo

var _current_shots: int = 0
var _shot_blueprint: S_Shot

var current_shots: int:
	get: return _current_shots
var cooldown_left: float:
	get: return shot_cooldown_timer.time_left
var time_till_reload: float:
	get: return reload_timer.time_left

func _ready() -> void:
	reset_weapon()
	reload_timer.timeout.connect(_reload)

func configure(blueprint: S_Muzzle) -> void:
	self.max_shots = blueprint.max_shots
	self.cooldown = blueprint.cooldown
	self.reload_time = blueprint.reload_time
	self._shot_blueprint = blueprint.shot
	reset_weapon()

func get_state_for_ai() -> Array:
	return [
		max_shots,
		_current_shots,
		shot_cooldown_timer.time_left,
		reload_timer.time_left,
	]

func fire(reference_velocity: Vector2, team: S_Team) -> void:
	if !shot_cooldown_timer.is_stopped():
		#print("the weapon is on cooldown")
		return
	if _current_shots <= 0 :
		#print("no bullets left!")
		out_of_ammo.pitch_scale = randf_range(0.97, 1.03)
		out_of_ammo.play()
		return 

	var bullet: Shot = SHOT.instantiate()
	get_viewport().add_child(bullet)
	bullet.add_to_group("SplitsAsteroids")
	if bullet.damage > 0:
		bullet.add_to_group("DamageCollider")
	bullet.transform = self.global_transform
	bullet.linear_velocity = reference_velocity
	bullet.configure(self._shot_blueprint, team)
	bullet.set_meta("origin", self.get_path())
	
	
	_current_shots -= 1
	shot_cooldown_timer.start()
	
	if reload_timer.is_stopped():
		reload_timer.start()
	
	pew.pitch_scale = randf_range(0.97, 1.03)
	pew.play()
	
## Resets the weapon to its default state (completelly loaded and timers on max cooldown)
func reset_weapon() -> void:
	_current_shots = max_shots
	
	shot_cooldown_timer.wait_time = cooldown
	shot_cooldown_timer.stop()
	reload_timer.wait_time = reload_time
	reload_timer.stop()
	
	var self_path := self.get_path()
	for shot: Shot in get_viewport().get_children().filter(func(c: Node): return c is Shot and c.get_meta("origin") == self_path):
		shot.queue_free()

func _reload() -> void:
	self._current_shots = move_toward(_current_shots, max_shots, 1)
	if _current_shots >= max_shots:
		reload_timer.stop()
