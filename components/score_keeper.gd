class_name ScoreKeeper 
extends Node

@export var bus: SignalBus

var score: int = 0:
	set(value):
		value = max(0, value)
		score_changed.emit(value)
		score = value

signal score_changed(new_score: int)

func _ready() -> void:
	bus.asteroid_destroyed.connect.call_deferred(
		func(points):score += points
	)
