class_name TeamScore
extends VBoxContainer

@onready var score_label: Label = %ScoreLabel
@onready var best_label: Label = %BestLabel

@export var team: Fight.Team

func show_score(score: int) -> void:
	score_label.text = "Score: %05d" % score
	
func show_best(best: int) -> void:
	best_label.text = "Best:   %05d" % best
