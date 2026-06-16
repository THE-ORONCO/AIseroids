class_name SpaceMulti
extends Node2D



## this decides if this is a highscore game or if all progress is reset after the time is up.
@export var play_mode: bool = false
@export var fit_to_screen := true

@export_group("asteroid spawning")
## The delay in seconds after which the space checks if new asteroids should spawn.
@export var wave_trigger_check_delay: int = 0
## The amount of time that is available to clear the wave
@export var time_clear_max_time: int = 120
@export var wave_size: int = 3
@export var wave_max_size_deviation: int = 1
@export var asteroid_spawn_delay: float = 3.
@export var asteroid_spawn_delay_max_deviation: float = 2.5
@export var target_asteroid_instances: int = 3


@export_group("AI")
enum AiMode {
	NONE,
	LEARNING,
	REPLAY,
}
@export var ai_mode: AiMode = AiMode.NONE 
@export var onnx_model_path: String

signal end_through_death
signal end_through_self
signal end_through_win
signal end_through_timeout

@onready var brains: Dictionary[NodePath, ShipBrain2D] = {}
@onready var score_keeper: ScoreKeeper = %ScoreKeeper
@onready var hud: Hud = %Hud
@onready var asteroid_spawner: AsteroidSpawner = %AsteroidSpawner
@onready var wrap: Wrap = %Wrap
@onready var camera: Camera2D = %Camera

var middle_of_wrap: Vector2:
	get: return wrap.global_position + wrap.extent / 2.

var ships: Array[Ship] = []

var _wave_spawn_timer: Timer
var _timeout_timer: Timer
var _is_resetting: bool = false

func _ready() -> void:
	_wave_spawn_timer = Timer.new()
	_wave_spawn_timer.autostart = true
	_wave_spawn_timer.one_shot = true
	_wave_spawn_timer.timeout.connect(random_wave)
	add_child(_wave_spawn_timer)

	for c in self.get_children():
		if c is Ship:
			_add_ship(c)
	self.child_entered_tree.connect(func(c):
			if c is Ship:	
				_add_ship(c))
	self.child_exiting_tree.connect(func(c):	
		if c is Ship:	_remove_ship(c))	
	
	wrap.do_fit_to_screen(fit_to_screen)
		
	if play_mode:
		spawn_or_wait()
	else:
		asteroid_spawner.wave_destroyed.connect(reset_playfield)
		_timeout_timer = Timer.new()
		_timeout_timer.autostart = true
		_timeout_timer.one_shot = true
		_timeout_timer.timeout.connect(reset_playfield)
		add_child(_timeout_timer)
	
	for ship in ships:
		ship.health_reached_zero.connect(reset_playfield)
	
	score_keeper.score_changed_for.connect(func(new_score: int, team: Fight.Team): 
		for ship in ships:
			if ship.team == team:
				ship.controller.score = new_score
		)
	score_keeper.score_changed_for.connect(hud.show_score)
	score_keeper.best_changed_for.connect(hud.show_best)
		
	camera.global_position = middle_of_wrap
	


	self.ready.connect(reset_playfield, CONNECT_ONE_SHOT)


func spawn_or_wait():
	if asteroid_spawner.get_child_count() < target_asteroid_instances:
			random_wave()
			await asteroid_spawner.finished_wave
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
	var circle_frac := TAU / float(ships.size())
	for i in range(ships.size()):
		var ship: Ship = ships[i]
		var brain: ShipBrain2D = brains.get(ship.get_path(), null)
		if ship.health_manager.health_current == 0:
			_reset_with_failure(ship, brain)
		elif _timeout_timer && _timeout_timer.is_stopped():
			_reset_with_timeout(ship, brain)
		else:
			_reset_with_success(ship, brain)
		var radial_offset := circle_frac * i
		var radius := wrap.extent.y / 4.
		var ship_i_pos := middle_of_wrap + Vector2(radius, 0.).rotated(radial_offset)
		ship.reset_ship(ship_i_pos)
		if brain:
			brain.reset()
		
	# spawn the next wave after a delay
	_wave_spawn_timer.start(wave_trigger_check_delay)
	
	# setup the timeout
	if not play_mode:
		_timeout_timer.start(time_clear_max_time)
	
	_is_resetting = false


func _reset_with_success(ship: Ship, brain: ShipBrain2D) -> void:
	if _is_resetting: return
	_is_resetting = true
	#print(get_meta("agent_no"),"success")
	if brain:
		brain.done = true
		brain.is_success = true
		
	end_through_win.emit()

func _reset_with_failure(ship: Ship, brain: ShipBrain2D) -> void:
	if _is_resetting: return
	_is_resetting = true
	#print(self.get_meta("agent_no"), "failure")
	if brain:
		brain.done = true
		brain.is_success = false

	if ship.controller.last_damage_was_self_damage:	end_through_self.emit()
	else: 											end_through_death.emit()


func _reset_with_timeout(ship: Ship, brain: ShipBrain2D) -> void:
	if _is_resetting: return
	_is_resetting = true
	#print(self.get_meta("agent_no"), "failure")
	if brain:
		brain.done = true
		brain.is_success = false

	reset_playfield.call_deferred()
	end_through_timeout.emit()
	

func _add_ship(ship: Ship) -> void:
	var i := ships.find(ship)
	if i >= 0: return # unknown ship
	
	ships.append(ship)
	print("added ship")
	if ship.controller is AiController:
		var brain := ShipBrain2D.new(ship.controller)
		brains[ship.get_path()] = brain
		add_child(brain)

		match ai_mode:
			AiMode.NONE: 		pass
			AiMode.LEARNING:	
				brain.control_mode = ShipBrain2D.ControlModes.TRAINING
				print("added learnign brain for ship ", ship.get_path())

			AiMode.REPLAY:
				brain.control_mode = ShipBrain2D.ControlModes.ONNX_INFERENCE
				brain.onnx_model_path = onnx_model_path
				print("added brain for ship ", ship.get_path(), " using model: ", onnx_model_path)
				

func _remove_ship(ship: Ship) -> void:
	var i := ships.find(ship)
	if i < 0: return # unknown ship
	
	
	if brains.erase(ship.get_path()):
		print("removed brain of ship ", ship.get_path())
	ships.remove_at(i)
	print("remove ship")
