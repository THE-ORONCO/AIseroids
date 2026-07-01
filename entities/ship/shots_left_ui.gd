class_name ShotsLeftUI
extends Node2D
## TODO: Implement shots rotating around the ship in a way that does not get influenced by the ships ratation.

const SHOT_MARKER = preload("uid://dxaftm04ytjgs")

var rotation_progress: float = 0.0
var progress_speed: float = 1.0
var markers: Array[PathFollow2D] = []

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
	var create_count: int = max_shot_count
	var spread_distance = 1.0 / max_shot_count
	reset()
	while create_count > 0:
		var shot_marker_instance := SHOT_MARKER.instantiate() as PathFollow2D
		rotation_path.add_child(shot_marker_instance)
		shot_marker_instance.progress_ratio = spread_distance * (max_shot_count - create_count)
		create_count -= 1
		markers.append(shot_marker_instance)


func reset() -> void:
	markers.clear()
	while rotation_path.get_child_count() > 0:
		var child = rotation_path.get_child(0)
		rotation_path.remove_child(child)
		child.queue_free()


func show_shots(count: int)  -> void:
	var set_visible_count := count
	for marker in rotation_path.get_children():
		marker.visible = set_visible_count > 0
		set_visible_count -= 1
