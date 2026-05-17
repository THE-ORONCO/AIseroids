class_name ScoreKeeper 
extends Node

@export var bus: SignalBus

var score: int = 0:
	set(value):
		value = max(0, value)
		score_changed.emit(value)
		score = value
		best = maxi(best, score)
		
var best: int = 0:
	set(val):
		if val > best:
			best_changed.emit(val)
		best = val

signal score_changed(new_score: int)
signal best_changed(new_best: int)

func _ready() -> void:
	bus.asteroid_destroyed.connect.call_deferred(
		func(points):score += points
	)

## Reset the score
func reset_score() -> void:
	score = 0
