class_name HealthManager
extends Resource


signal health_changed(new_health: int)
signal health_reached_zero()

@export var health_current: int:
	set(value):
		health_current = clamp(0, value, health_max)
@export var health_max: int:
	set(value):
		health_max = max(1, value)
		health_current = min(health_current, value)
@export_category("Visual Feedback")
@export var show_visual_feedback := true
@export var health_change_color_postive := Color(0,1,0,1) 
@export var health_change_color_negative := Color(1,0,0,1) 

var owner_node: CollisionObject2D


func _init(new_owner_node: CollisionObject2D, new_health_max: int) -> void:
	owner_node = new_owner_node
	health_max = new_health_max
	health_current = new_health_max


func apply_health_change(health_change: int) -> void:
	if not owner_node:
		push_error("Health manager exists without owner")
		return
	health_current += health_change
	_apply_health_change_visuals(health_change)
	health_changed.emit(health_current, health_change)
	if health_current <= 0:
		health_reached_zero.emit()


func _apply_health_change_visuals(health_change: int) -> void:
	if not show_visual_feedback:
		return

	var original_modulate: Color = owner_node.get_modulate()
	var flicker_color: Color

	if health_change > 0:
		flicker_color = health_change_color_postive
	elif health_change < 0:
		flicker_color = health_change_color_negative
	else:
		return


	var to_flicker_time := 0.05
	var back_time := 0.10

	# Ensure exact start value
	owner_node.set_modulate(original_modulate)

	# Create one-shot SceneTreeTween
	var tween := owner_node.create_tween()

	tween.tween_property(owner_node, "modulate", flicker_color, to_flicker_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(owner_node, "modulate", original_modulate, back_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(to_flicker_time)
