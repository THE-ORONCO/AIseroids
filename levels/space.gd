class_name Space
extends Node2D



## this decides if this is a highscore game or if all progress is reset after the time is up.
@export var play_mode: bool = false


@export_group("asteroid spawning")
## The delay in seconds after which the space checks if new asteroids should spawn.
@export var wave_trigger_check_delay: int = 0
## The amount of time that is available to clear the wave
@export var time_clear_max_time: int = 120
@export var wave_size: int = 5
@export var wave_max_size_deviation: int = 3
@export var asteroid_spawn_delay: float = 3.
@export var asteroid_spawn_delay_max_deviation: float = 2.5
@export var target_asteroid_instances: int = 20


@export_group("AI")
enum AiMode {
	NONE,
	LEARNING,
	REPLAY,
}
@export var ai_mode: AiMode = AiMode.NONE 
@export var onnx_model_path: String
@export_subgroup("hyper params")
@export_range(0., 10.) var damage_reward_scale := 1.
@export_range(0., 10.) var point_reward_scale := 1.


signal end_through_death
signal end_through_win
signal end_through_timeout

@onready var ship: Ship = %Ship
@onready var score_keeper: ScoreKeeper = %ScoreKeeper
@onready var hud: Hud = %Hud
@onready var asteroid_spawner: AsteroidSpawner = %AsteroidSpawner
@onready var wrap: Wrap = %Wrap
@onready var camera: Camera2D = %Camera

var middle_of_wrap: Vector2:
	get: return wrap.global_position + wrap.extent / 2.

var _ship_brain: ShipBrain2D
var _wave_spawn_timer: Timer
var _timeout_timer: Timer
var _is_resetting: bool = false

func _ready() -> void:
	_wave_spawn_timer = Timer.new()
	_wave_spawn_timer.autostart = true
	_wave_spawn_timer.one_shot = true
	_wave_spawn_timer.timeout.connect(random_wave)
	add_child(_wave_spawn_timer)
	
	_timeout_timer = Timer.new()
	_timeout_timer.autostart = true
	_timeout_timer.one_shot = true
	_timeout_timer.timeout.connect(_reset_with_timeout)
	add_child(_timeout_timer)
	
	if play_mode:
		asteroid_spawner.finished_wave.connect(spawn_or_wait)
	else:
		asteroid_spawner.wave_destroyed.connect(_reset_with_success)
	
	ship.health_reached_zero.connect(_reset_with_failure)
	
	score_keeper.score_changed.connect(func(ns): 
		ship.controller.score = ns
		hud.show_score(ns)
		)
	score_keeper.best_changed.connect(hud.show_best)
		
	camera.global_position = middle_of_wrap
	
	_wire_up_agent()
	
	reset_playfield.call_deferred()


func spawn_or_wait():
	if asteroid_spawner.get_child_count() < target_asteroid_instances:
			random_wave()
	else:
		get_tree().create_timer(10).timeout.connect(spawn_or_wait, CONNECT_ONE_SHOT)

func random_wave() -> void:
	var random_wave_size := wave_size + randi_range(-wave_max_size_deviation, wave_max_size_deviation)
	var random_spawn_delay := asteroid_spawn_delay + randf_range(-asteroid_spawn_delay_max_deviation, asteroid_spawn_delay_max_deviation)
	asteroid_spawner.spawn_wave(random_wave_size, random_spawn_delay)

func reset_playfield() -> void:
	#print(get_meta("agent_no"),"reset playfield")
	
	# reset the play field
	score_keeper.reset_score()
	asteroid_spawner.clear_asteroids()
	ship.reset_ship(middle_of_wrap)
	
	# reset the brain
	if _ship_brain:
		_ship_brain.reset()
		
		#_ship_brain.done = false
		#_ship_brain.is_success = false
		
	# spawn the next wave after a delay
	_wave_spawn_timer.start(wave_trigger_check_delay)
	
	# setup the timeout
	if not play_mode:
		_timeout_timer.start(time_clear_max_time)
	
	_is_resetting = false

func _reset_with_success() -> void:
	if _is_resetting: return
	_is_resetting = true
	#print(get_meta("agent_no"),"success")
	if _ship_brain:
		_ship_brain.done = true
		_ship_brain.is_success = true
		
	reset_playfield.call_deferred()
	end_through_win.emit()

func _reset_with_failure() -> void:
	if _is_resetting: return
	_is_resetting = true
	#print(self.get_meta("agent_no"), "failure")
	if _ship_brain:
		_ship_brain.done = true
		_ship_brain.is_success = false

	reset_playfield.call_deferred()
	end_through_death.emit()

func _reset_with_timeout() -> void:
	if _is_resetting: return
	_is_resetting = true
	#print(self.get_meta("agent_no"), "failure")
	if _ship_brain:
		_ship_brain.done = true
		_ship_brain.is_success = false

	reset_playfield.call_deferred()
	end_through_timeout.emit()

func _wire_up_agent() -> void:
	match ai_mode:
		AiMode.NONE: 
			var controller := PlayerController.new()
			add_child(controller)
			ship.controller = controller
			
		AiMode.LEARNING:
			var controller := AiController.new()
			add_child(controller)
			ship.controller = controller
			
			_ship_brain = ShipBrain2D.new(controller)
			_ship_brain.controller = controller
			_ship_brain.control_mode = ShipBrain2D.ControlModes.TRAINING
			add_child(_ship_brain)

		AiMode.REPLAY:
			var controller := AiController.new()
			add_child(controller)
			ship.controller = controller
			
			_ship_brain = ShipBrain2D.new(controller)
			_ship_brain.controller = controller
			_ship_brain.control_mode = ShipBrain2D.ControlModes.ONNX_INFERENCE
			_ship_brain.onnx_model_path = onnx_model_path
			add_child(_ship_brain)
