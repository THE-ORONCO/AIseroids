class_name HealthBar
extends Control


@export var health_manager: HealthManager


func _ready() -> void:
	if health_manager == null:
		push_warning("no health_manager asigned - nothing to display")
		hide()
