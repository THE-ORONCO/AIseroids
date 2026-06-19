class_name Hud
extends MarginContainer

@export var wrap_space: Wrap

@onready var teams: HBoxContainer = %Teams

var shown_teams: Dictionary[S_Team, TeamScore]

const TEAM_SCORE = preload("uid://bcjpw6eddpiff")


func show_score(score: int, team: S_Team) -> void:
	if !shown_teams.has(team):
		add_team(team)

	shown_teams[team].show_score(score)

	
func show_best(best: int, team: S_Team) -> void:
	if !shown_teams.has(team):
		add_team(team)
	
	shown_teams[team].show_best(best)


func _ready() -> void:
	resize_to_wrap()
	wrap_space.size_changed.connect(resize_to_wrap)
	

func resize_to_wrap() -> void:
	self.custom_minimum_size = wrap_space.extent

func add_team(team: S_Team) -> void:
	if shown_teams.has(team):
		return
	
	var team_score: TeamScore = TEAM_SCORE.instantiate()
	team_score.team = team
	teams.add_child(team_score)
	shown_teams.set(team, team_score)
