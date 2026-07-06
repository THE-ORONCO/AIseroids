class_name EndScreen
extends Control

const TEAM_SCORE: PackedScene = preload("uid://bcjpw6eddpiff")
const TEXT_PROMPT_WINDOW: PackedScene = preload("uid://douh70nt8yht8")

@onready var score_container: VBoxContainer = %ScoreContainer
@onready var winner_label: RichTextLabel = %WinnerLabel
@onready var main_menu_button: Button = %MainMenuButton
@onready var highscore_board: HighscoreBoard = %HighscoreBoard

var scores: Dictionary[S_Team, int] = {}
var game_mode: String

func _ready() -> void:
	main_menu_button.pressed.connect(_back_to_main_menu)
	
	update_scores()

func update_scores() -> void:
	assert(scores.size() > 0, "at least one score should be submitted")
	
	for child in score_container.get_children(): 
		child.queue_free()
	
	var best_teams: Array[String] = []
	var best_score := -1
	
	for team in scores:
		var score: int = scores.get(team, 0)
		var score_panel: TeamScore = TEAM_SCORE.instantiate()
		score_container.add_child(score_panel)
		score_panel.show_score(score)
		score_panel._refresh_team(team)
		score_panel.best_label.hide()
		
		
		if score > best_score:
			best_score = score
			best_teams = [team.name]
		elif score == best_score:
			best_teams.append(team.name)
	
	var best_team_string: String = best_teams.reduce(func(a,b): return "%s & %s" % [a,b])
	winner_label.text = "[wave][rainbow freq=0.4 sat=0.8 val=0.8 speed=1.1]%s[/rainbow][/wave] won with [wave][rainbow freq=0.4 sat=0.8 val=0.8 speed=1.1]%d[/rainbow][/wave] points" % [best_team_string, best_score]
	
	if game_mode:
		var score_list := ScoreLists.load_or_create()
		for team in best_teams:
			score_list.save_score(game_mode, team, best_score)
		
		highscore_board.display_score_list(score_list, game_mode)

func _back_to_main_menu() -> void:
	var res := get_tree().change_scene_to_file("uid://byxh5am80srpe")
	print(res)
