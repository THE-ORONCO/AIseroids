extends Node2D

## The delay in seconds after which the space checks if new asteroids should spawn.
@export var wave_trigger_check_delay: int = 5 
@export var wave_size: int = 5
@export var asteroid_spawn_delay: int = 3
@export var target_asteroid_instances: int = 20


func _ready() -> void:
	get_tree().create_timer(wave_trigger_check_delay).timeout.connect(
		func():
			if %AsteroidSpawner.get_children().size() < target_asteroid_instances:
				%AsteroidSpawner.spawn_wave(5, 3)
	)
