class_name HealthBar
extends Control


# Put this in ship to activate:



@onready var progress_bar: ProgressBar = $ProgressBar


func _ready() -> void:
	pass
	#await get_tree().create_timer(2).timeout
	#hide()


func set_up_progress_bar(health_manager_res: HealthManager):
	if health_manager_res == null:
		push_error("Set up failed - health manager is null")
	elif progress_bar == null:
		push_error("Set up failed - progress bar not ready")
	else:
		progress_bar.max_value = health_manager_res.health_max
		progress_bar.value = health_manager_res.health_current
		if not health_manager_res.health_changed.is_connected(_update_progress):
			health_manager_res.health_changed.connect(_update_progress)


func _update_progress(new_value: int) -> void:
	progress_bar.value = new_value
