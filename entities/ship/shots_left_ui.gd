class_name ShotsLeftUI
extends Node2D
## TODO: Implement shots rotating around the ship in a way that does not get influenced by the ships ratation.

const SHOT_MARKER = preload("uid://dxaftm04ytjgs")

var rotation_progress: float = 0.0
var progress_speed: float = 1.0
var markers: Array[PathFollow2D] = []
var _max_shot_count: int = 0

@onready var rotation_path: Path2D = $RotationPath
@onready var parent: Node2D = self.get_parent()

@onready var before := parent.global_rotation
func _physics_process(delta: float) -> void:
	var current := parent.global_rotation
	var rot_delta := current - before
	self.rotation -= rot_delta
	before = current
	
	for marker in markers:
		marker.progress += progress_speed

func configure(max_shot_count: int) -> void:
	_max_shot_count = max_shot_count
	
	reset()
	

func reset() -> void:
	clear()
	var spread_distance = 1.0 / _max_shot_count
	for create_count in range(_max_shot_count, 0, -1):
		var shot_marker_instance := SHOT_MARKER.instantiate() as PathFollow2D
		rotation_path.add_child(shot_marker_instance)
		shot_marker_instance.progress_ratio = spread_distance * (_max_shot_count - create_count)
		markers.append(shot_marker_instance)

func clear() -> void:
	markers.clear()
	for child in rotation_path.get_children():
		child.queue_free()

func show_shots(count: int)  -> void:
	var set_visible_count := count
	for marker in rotation_path.get_children():
		marker.visible = set_visible_count > 0
		set_visible_count -= 1
