class_name Scenario
extends Resource


@export_group("fighters")
## The ships that will participate in the fight. 
## They will be spawned in a circle in the center of the play field.
@export var ships: Array[S_Ship] = []

@export_group("gameplay")
@export var limit_time: bool = false
## The amount of time that is available to clear the wave.
@export_range(0, 120, .1, "or_greater") var time_clear_max_time: float = 120
## if the play field should be fit to the screen
@export var fit_to_screen := false
## the extent to be used for the playfield if it does not fit to screen
@export var playfield_extent := Vector2(1000, 1000)

@export_group("asteroid spawning")
## The delay in seconds after which the space checks if new asteroids should spawn.
@export_range(0, 10, .1, "or_greater") var wave_trigger_check_delay: float = 0.
## The average wave size.
@export_range(0, 10, 1, "or_greater") var wave_size: int = 3
## min and max deviation of the number of asteroids spawned 
@export_range(0, 5, 1, "or_greater") var wave_max_size_deviation: int = 1
## the delay of the asteroid spawn
@export_range(0, 5, .1, "or_greater") var asteroid_spawn_delay: float = 3.
## the random deviation of the spawn delay
@export_range(0, 5, .1, "or_greater") var asteroid_spawn_delay_max_deviation: float = 2.5
## if less than this amount of asteroids exist no more are spawned even if the timer runs out
@export_range(0, 10, 1, "or_greater") var target_asteroid_instances: int = 3


@export_group("visuals & sfx")
## if debug graphics should be shown
@export var debug_info := false
## if the sounds should be muted globally
@export var mute_sounds := true
