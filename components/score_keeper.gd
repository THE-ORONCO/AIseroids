class_name ScoreKeeper 
extends Node


@export var bus: SignalBus

var scores: Dictionary[S_Team, int] = {}
var bests: Dictionary[S_Team, int] = {}
var _score_lists: ScoreLists

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

signal score_changed_for(new_score: int, team: S_Team)
signal best_changed_for(new_best: int, team: S_Team)
signal score_changed(new_score: int)
signal best_changed(new_best: int)

func _ready() -> void:
	bus.asteroid_destroyed.connect.call_deferred(_increment_score)
	_score_lists = ScoreLists.load_or_create()

## Reset the scores
func reset_score() -> void:
	score = 0
	scores = {}

func get_score(team: Fight.Team) -> int:
	return scores.get(team, 0.)

func get_best(team: Fight.Team) -> int:
	return bests.get(team, 0.)

func _increment_score(team: S_Team, value: int) -> void:
	var score_before: int = scores.get(team, 0)
	var new_score := score_before + value
	set_score(team, new_score)
	
func set_score(team: S_Team, value: int) -> void:
		value = max(0, value)
		score_changed_for.emit(value, team)
		scores[team] = value
		var best_before: int = bests.get(team, 0)
		if value > best_before:
			bests[team] = value
			best_changed_for.emit(value, team)

func save_highscore(game_mode: String, entry_name: String, highscore: int) -> void:
	assert(_score_lists != null, "Can't save! No scorelist resource was loaded.")
	_score_lists.save_score(game_mode, entry_name, highscore)
