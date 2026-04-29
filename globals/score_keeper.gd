extends Node

var score: int = 0

func _ready() -> void:
	SignalBus.asteroid_destroyed.connect.call_deferred(
		func(points):score += points
	)
