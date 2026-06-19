class_name TeamScore
extends Control

@onready var score_label: Label = %ScoreLabel
@onready var best_label: Label = %BestLabel
@onready var team_name: Label = %TeamName

@export var team: S_Team:
	set(val): team = _refresh_team(val)

func _ready() -> void:
	_refresh_team(team)

func _refresh_team(new_team: S_Team) -> S_Team:
	if new_team:
		self.modulate = new_team.color
		if team_name:
			team_name.text = new_team.name
	return new_team

func show_score(score: int) -> void:
	score_label.text = "Score: %05d" % score
	
func show_best(best: int) -> void:
	best_label.text = "Best:   %05d" % best
