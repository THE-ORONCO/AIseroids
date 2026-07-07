class_name SpaceMulti
extends Node2D

const SHIP = preload("uid://cunuddi5si8ua")


## this decides if this is a highscore game or if all progress is reset after the time is up.
@export var limit_time: bool = false
## if the game has multiple waves or if it ends after one
@export var multi_wave: bool = true
@export var fit_to_screen := false
@export var playfield_extent := Vector2(1000., 1000.)

@export_group("asteroid spawning")
## The delay in seconds after which the space checks if new asteroids should spawn.
@export_range(0, 10, .1, "or_greater") var wave_trigger_check_delay: float = 0
## The amount of time that is available to clear the wave
@export_range(0,180,1,"or_greater") var time_clear_max_time: float = 120.
@export var wave_size: int = 3
@export var wave_max_size_deviation: int = 1
@export var asteroid_spawn_delay: float = 3.
@export var asteroid_spawn_delay_max_deviation: float = 2.5
@export var target_asteroid_instances: int = 3


@export var onnx_model_path: String

signal end_through_death
signal end_through_self
signal end_through_win
signal end_through_timeout
signal round_finished(scores: Dictionary[S_Team, int])

@onready var brains: Dictionary[NodePath, ShipBrain2D] = {}
@onready var score_keeper: ScoreKeeper = %ScoreKeeper
@onready var hud: Hud = %Hud
@onready var asteroid_spawner: AsteroidSpawner = %AsteroidSpawner
@onready var wrap_border: Wrap = %Wrap
@onready var camera: TraumaCamera = %Camera
@onready var signal_bus: SignalBus = %SignalBus

var middle_of_wrap: Vector2:
	get: return wrap_border.global_position + wrap_border.extent / 2.

var ships: Array[Ship] = []
var ships_have_ai: bool:
	get: return !brains.is_empty()

var _wave_spawn_timer: Timer
var _timeout_timer: Timer
var _is_resetting: bool = false

func _ready() -> void:	
	_wave_spawn_timer = Timer.new()
	_wave_spawn_timer.autostart = true
	_wave_spawn_timer.one_shot = true
	_wave_spawn_timer.timeout.connect(random_wave)
	add_child(_wave_spawn_timer)

	wrap_border.fallback_size = self.playfield_extent
	wrap_border.do_fit_to_screen(fit_to_screen)
	
	asteroid_spawner.wave_destroyed.connect(_handle_wave_destroyed)
	
	signal_bus.asteroid_destroyed.connect(func(_t,_p): camera.shake_screen(5))
	signal_bus.shot_hit_ship.connect(func(shot: Shot, hit_ship: Ship):
		# TODO find a better solution than to itterate all ships (though with so few ships it should not matter)
		for ship in ships:
			if ship == hit_ship:
				if shot.team == ship.team: # self damage
					ship.controller.shot_self = true
				if shot.team != ship.team: # other team hit
					ship.controller.shot_by_enemy = true
			# TODO associate the shot with the ship that shot so we do not use the team here
			#  this will break if we ever put more than one ship in a team
			if ship.team == shot.team:
				ship.controller.shot_enemy = true
		)
	
	
	_timeout_timer = Timer.new()
	_timeout_timer.one_shot = true
	_timeout_timer.timeout.connect(reset_playfield)
	add_child(_timeout_timer)
	
	score_keeper.score_changed_for.connect(hud.show_score)
	score_keeper.best_changed_for.connect(hud.show_best)
	
	#self.ready.connect(reset_playfield, CONNECT_ONE_SHOT)

func _shake_camera(_ignored) -> void:
	camera.shake_screen()


func configure(blueprint: Scenario) -> void:
	for ship_blueprint in blueprint.ships:
		var ship := _create_ship(ship_blueprint)
		ship.health_reached_zero.connect(reset_playfield)
		ship.bus = signal_bus
		score_keeper.score_changed_for.connect(ship.apply_score)
		ship.health_changed.connect(_shake_camera)
		
	self.time_clear_max_time = blueprint.time_clear_max_time
	
	self.asteroid_spawn_delay = blueprint.asteroid_spawn_delay
	self.asteroid_spawn_delay_max_deviation = blueprint.asteroid_spawn_delay_max_deviation
	self.wave_size = blueprint.wave_size
	self.wave_max_size_deviation = blueprint.wave_max_size_deviation
	self.wave_trigger_check_delay = blueprint.wave_trigger_check_delay
	
	self.fit_to_screen = blueprint.fit_to_screen
	self.playfield_extent = blueprint.playfield_extent
	self.limit_time = blueprint.limit_time
	self.multi_wave = blueprint.multi_wave
	self.target_asteroid_instances = blueprint.target_asteroid_instances
	
	
	# TODO use these somehow
	blueprint.debug_info
	blueprint.mute_sounds
	reset_playfield(false)

func spawn_or_wait():
	if asteroid_spawner.get_child_count() < target_asteroid_instances:
			_wave_spawn_timer.start(wave_trigger_check_delay)
			if !_wave_spawn_timer.is_stopped():
				await _wave_spawn_timer.timeout
			await asteroid_spawner.finished_wave
	if !limit_time:
		get_tree().create_timer(10).timeout.connect(spawn_or_wait, CONNECT_ONE_SHOT)

func random_wave() -> void:
	var random_wave_size := wave_size + randi_range(-wave_max_size_deviation, wave_max_size_deviation)
	var random_spawn_delay := asteroid_spawn_delay + randf_range(-asteroid_spawn_delay_max_deviation, asteroid_spawn_delay_max_deviation)
	asteroid_spawner.spawn_wave(random_wave_size, random_spawn_delay)

func reset_playfield(report_reset := true) -> void:
	wrap_border.fallback_size = self.playfield_extent
	wrap_border.do_fit_to_screen(fit_to_screen)
	camera.global_position = middle_of_wrap
	
	score_keeper.reset_score()
	asteroid_spawner.clear_asteroids()
	var circle_frac := TAU / float(ships.size())
	for i in range(ships.size()):
		var ship: Ship = ships[i]
		var brain: ShipBrain2D = brains.get(ship.get_path(), null)
		if report_reset: # TODO check if this toggle is the right solution
			if ship.health_manager.health_current == 0:
				_reset_with_failure(ship, brain)
			elif _timeout_timer && _timeout_timer.is_stopped():
				_reset_with_timeout(ship, brain)
			else:
				_reset_with_success(ship, brain)
		
		var ship_i_pos := middle_of_wrap
		if ships.size() > 1:
			var radial_offset := circle_frac * i
			var radius := wrap_border.extent.y / 4.
			ship_i_pos += Vector2(radius, 0.).rotated(radial_offset)
		ship.reset_ship(ship_i_pos)
		if brain:
			brain.reset()
	
	# setup the timeout
	if limit_time:
		_wave_spawn_timer.start(wave_trigger_check_delay)
		_timeout_timer.start(time_clear_max_time)
	else:
		spawn_or_wait()
	
	_is_resetting = false
	
	if report_reset:
		round_finished.emit(score_keeper.bests)

func _reset_with_success(_ship: Ship, brain: ShipBrain2D) -> void:
	if _is_resetting: return
	_is_resetting = true
	if brain:
		brain.done = true
		brain.is_success = true
		
	end_through_win.emit()

func _reset_with_failure(ship: Ship, brain: ShipBrain2D) -> void:
	if _is_resetting: return
	_is_resetting = true
	if brain:
		brain.done = true
		brain.is_success = false

	if ship.controller.shot_self:	end_through_self.emit()
	else: 							end_through_death.emit()


func _reset_with_timeout(_ship: Ship, brain: ShipBrain2D) -> void:
	if _is_resetting: return
	_is_resetting = true
	if brain:
		brain.done = true
		brain.is_success = false

	reset_playfield.call_deferred()
	end_through_timeout.emit()
	
func _create_ship(blueprint: S_Ship) -> Ship:
	var ship: Ship = SHIP.instantiate()
	self.add_child(ship)
	ships.append(ship)
	
	var mode := blueprint.mode
	var controller: ShipController
	
	if mode is CM_Inference:
		controller = AiController.new()
		ship.add_child(controller)
		
		var inf_mode: CM_Inference = mode
		var brain := ShipBrain2D.new(controller)
		brain.control_mode = ShipBrain2D.ControlModes.ONNX_INFERENCE
		brain.onnx_model_path = inf_mode.model_path
		ship.add_child(brain)
		brains[ship.get_path()] = brain

	elif mode is CM_Training:
		controller = AiController.new()
		ship.add_child(controller)
		
		var train_mode: CM_Training = mode
		var brain := ShipBrain2D.new(controller)
		brain.control_mode = ShipBrain2D.ControlModes.TRAINING
		#brain.action_repeat = 1
		ship.add_child(brain)
		brains[ship.get_path()] = brain
 
	elif mode is CM_Player:
		controller = PlayerController.new()
		ship.add_child(controller)
	else:					
		assert(false, "unknown controller mode")
	assert(controller != null, "we should have a controller at this point")
	
	ship.configure(blueprint, controller)

	return ship
	

func _handle_wave_destroyed() -> void:
	if !multi_wave:
		reset_playfield()
