extends Node

var score: int = 0:
	set(value):
		value = max(0, value)
		score_changed.emit(value)
		score = value

signal score_changed(new_score: int)

func _ready() -> void:
	SignalBus.asteroid_destroyed.connect.call_deferred(
		func(points):score += points
	)
