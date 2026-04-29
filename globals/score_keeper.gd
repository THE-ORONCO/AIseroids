extends Node

var score: int = 0

signal score_changed(new_score: int)

func _ready() -> void:
	SignalBus.asteroid_destroyed.connect.call_deferred(
		func(points):score += points
	)
