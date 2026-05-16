class_name Space
extends Node2D

## The delay in seconds after which the space checks if new asteroids should spawn.
@export var wave_trigger_check_delay: int = 0
@export var wave_size: int = 5
@export var wave_max_size_deviation: int = 3
@export var asteroid_spawn_delay: float = 3.
@export var asteroid_spawn_delay_max_deviation: float = 2.5
@export var target_asteroid_instances: int = 20

@onready var ship: Ship = %Ship
@onready var score_keeper: ScoreKeeper = %ScoreKeeper
@onready var hud: Hud = %Hud
@onready var asteroid_spawner: AsteroidSpawner = %AsteroidSpawner
@onready var wrap: Wrap = %Wrap
@onready var camera: Camera2D = %Camera

var middle_of_wrap: Vector2:
	get: return wrap.global_position + wrap.extent / 2.


func _ready() -> void:
	get_tree().create_timer(wave_trigger_check_delay).timeout.connect(random_wave)
	
	asteroid_spawner.finished_wave.connect(spawn_or_wait)
	
	ship.health_reached_zero.connect(reset_playfiled.call_deferred)
	
	score_keeper.score_changed.connect(func(ns): 
		ship.controller.score = ns
		hud.show_score(ns)
		)
		
	camera.global_position = middle_of_wrap

func spawn_or_wait():
	if asteroid_spawner.get_child_count() < target_asteroid_instances:
			random_wave()
	else:
		get_tree().create_timer(10).timeout.connect(spawn_or_wait, CONNECT_ONE_SHOT)

func random_wave() -> void:
	var random_wave_size := wave_size + randi_range(-wave_max_size_deviation, wave_max_size_deviation)
	var random_spawn_delay := asteroid_spawn_delay + randf_range(-asteroid_spawn_delay_max_deviation, asteroid_spawn_delay_max_deviation)
	asteroid_spawner.spawn_wave(random_wave_size, random_spawn_delay)

func reset_playfiled() -> void:
	
	score_keeper.reset_score()
	asteroid_spawner.clear_asteroids()
	ship.reset_ship(middle_of_wrap)
