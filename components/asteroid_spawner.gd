class_name AsteroidSpawner
extends Node2D


const MAX_ATTEMPTS := 50
const ASTEROID: PackedScene = preload("uid://tm3wubyfx7r")

@export var wrap_instance: Wrap
@export var bus: SignalBus

var instances_max: int = 100
var spawn_force: float = 100.0
var spawns: bool = true
var rng: RandomNumberGenerator

var _wave_finished := false

signal finished_wave
signal wave_destroyed

func _ready() -> void:
	if wrap_instance == null:
		push_error("No wrap assigned. Spawn position cannot be calculated")
		spawns = false
	rng = RandomNumberGenerator.new()
	
	finished_wave.connect(_finish_wave)

		

## Spawns a wave of asteroids that enter the play field from a random position outside
## wave_size describes how many asteroids are spawned
## spawn_delay defines how long the spawner waits between each asteroid
## when finished the finished_wave signal is emmited
func spawn_wave(wave_size: int, spawn_delay: float) -> void:
	if wave_size < 1:
		return
	for i in range(wave_size):
		var wave_timer = get_tree().create_timer(spawn_delay * (i))
		wave_timer.timeout.connect(spawn)
		
		if i + 1 == wave_size: # the last wave
			wave_timer.timeout.connect(finished_wave.emit)
	
func _finish_wave() -> void:
	#print("finished spawning wave")
	_wave_finished = true

func spawn() -> void:
	if not spawns:
		return
	if get_children().size() >= instances_max:
		return
	var instance := ASTEROID.instantiate() as Asteroid
	instance.bus = bus
	add_child(instance)
	var collision_shape := instance.get_node_or_null(^"CollisionShape2D")
	if not collision_shape or not collision_shape.shape:
		push_error("ASTEROID scene needs a CollisionShape2D with a CircleShape2D.")
		return
	
	var last_position := Vector2.ZERO
	var edge := 0
	for i in range(MAX_ATTEMPTS):
		edge = rng.randi() % 4
		var spawn_position := _get_spawn_position(instance.collision_shape_2d.shape.radius, edge)
		last_position = spawn_position
		if _is_position_free(collision_shape.shape, spawn_position):
			instance.position = spawn_position
			_apply_spawn_impulse(instance, edge)
			return
	
	# fallback: place at last sampled spawn_position even if overlap check failed
	instance.position = last_position
	_apply_spawn_impulse(instance, edge)

## Frees all asteroids on the playfield
func clear_asteroids() -> void:
	_wave_finished = false
	for asteroid : Asteroid in self.get_children().filter(func(c): return c is Asteroid):
		asteroid.queue_free()

func _physics_process(delta: float) -> void:
	_check_field_clear.call_deferred()

func _check_field_clear() -> void:
	if _wave_finished && self.get_children().filter(func(c): return c is Asteroid).size() == 0:
		wave_destroyed.emit()
		_wave_finished = false

## Picks a spawn point outside the current wrap by chosing a random place on 
## the edge of the wrap and adding an offset so the ASTEROID is spawned outside.
func _get_spawn_position(asteroid_radius: float, edge: int) -> Vector2:
	var spawn_point: Vector2
	var spawn_offset = asteroid_radius + 50 
	var wrap_top = wrap_instance.position.y - spawn_offset
	var wrap_right = wrap_instance.position.x + wrap_instance.extent.x + spawn_offset
	var wrap_bottom = wrap_instance.position.y + wrap_instance.extent.y + spawn_offset
	var wrap_left = wrap_instance.position.x - spawn_offset
	match edge:
		0: spawn_point = Vector2(randf_range(wrap_left, wrap_right), wrap_top)
		1: spawn_point = Vector2(wrap_left, randf_range(wrap_top, wrap_bottom))
		2: spawn_point = Vector2(randf_range(wrap_left, wrap_right), wrap_bottom)
		3: spawn_point = Vector2(wrap_right, randf_range(wrap_top, wrap_bottom))
	
	return spawn_point


## Overlap test using direct space state
func _is_position_free(shape: Shape2D, pos: Vector2, margin: float = 0.01) -> bool:
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, pos)
	params.margin = margin
	var space := get_world_2d().direct_space_state
	var res := space.intersect_shape(params, 1)
	return res.is_empty()


## Applies an impusle towards the center of the wrap with a random offset 
## between + and - 20 degrees.
func _apply_spawn_impulse(body: RigidBody2D, edge: int) -> void:
	var target_pos: Vector2
	var wrap_top: float = wrap_instance.position.y 
	var wrap_right: float = wrap_instance.position.x + wrap_instance.extent.x
	var wrap_bottom: float = (wrap_instance.position + wrap_instance.extent).y
	var wrap_left: float = wrap_instance.position.x
	match edge:
		0: target_pos = Vector2(randf_range(wrap_left, wrap_right),wrap_bottom)
		1: target_pos = Vector2(wrap_right, randf_range(wrap_top, wrap_bottom))
		2: target_pos = Vector2(randf_range(wrap_left, wrap_right), wrap_top)
		3: target_pos = Vector2(wrap_left, randf_range(wrap_top, wrap_bottom))
	var direction := target_pos - body.position
	body.apply_central_impulse(direction.normalized() * spawn_force)
	
